//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI

struct NewEvent: View {
    
    @State var manager: NewEventManager
    
    @State private var showTypePicker: Bool = false
    @State private var showVisibilityPicker: Bool = false
    @State private var showSkillLevelPicker: Bool = false
    
    @State private var isEditing: Bool = false
    @State private var validationStatus: NEW_EVENT_ERROR = .unexpected
    @State private var hasEndTime: Bool = false
    
    @State private var showVenuePicker: Bool = false
    @State private var showSportsPicker: Bool = false
    
    @State private var showPostViolation: Bool = false
    @State private var showCompletedToast: Bool = false
    
    @State private var showStartTimePicker: Bool = false
    @State private var showStopTimePicker: Bool = false
    
    @State private var showAdvancedSettings: Bool = false
    @State private var showOrganizersPicker: Bool = false
    
    
    @FocusState private var titleFocus: Bool
    @FocusState private var descriptionFocus: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(SessionStore.self) private var session
    
    private let uploadObserver = UploadObserver()
    private let notificationsManager = NotificationManager()
    private let log = Logger(subsystem: "com.olympsis.client", category: "new_event_view")

    private var setStartTime: Int {
        return Int(manager.startDate.timeIntervalSince1970)
    }
    
    private var setStopTime: Int {
        return Int(manager.endDate.timeIntervalSince1970)
    }
    
    private var startTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - hh:mm a"
        return dateFormatter.string(from: manager.startDate)
    }
    
    private var stopTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - hh:mm a"
        return dateFormatter.string(from: manager.endDate)
    }
    
    private var hasSelectedVenue: Bool {
        return !manager.selectedVenues.isEmpty
    }
    
    private func handleFailure() {
        manager.status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            manager.status = .pending
        }
    }
    
    private func handleSuccess() {
        manager.status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    /// Validates the new event view
    ///
    /// This function makes sure that we have the right data populated.
    /// If we are missing some data we want to scroll the user down to where they need add more information
    ///
    /// - Parameter value: The scroll view proxy needed to scroll the user down to the specific location
    ///
    /// - Returns an optional `NEW_EVENT_ERROR` to let us know what went wrong
    func Validate(value: ScrollViewProxy) -> NEW_EVENT_ERROR? {
        // make sure we have a title
        guard !manager.title.isEmpty else {
            Task { @MainActor in
                validationStatus = .noTitle
                withAnimation {
                    value.scrollTo(1)
                }
            }
            return .noTitle
        }
        
        // make sure we have a description
        guard !manager.body.isEmpty else {
            Task { @MainActor in
                validationStatus = .noDescription
                withAnimation {
                    value.scrollTo(2)
                }
            }
            return .noDescription
        }
        
        // make sure we have selected venues
        guard !manager.selectedVenueDescriptors.isEmpty else {
            Task { @MainActor in
                validationStatus = .noSelectedField
                withAnimation {
                    value.scrollTo(3)
                }
            }
            return .noSelectedField
        }
        
        // make sure end date is greater than start
        guard manager.endDate > manager.startDate else {
            Task { @MainActor in
                validationStatus = .unexpected
                withAnimation {
                    value.scrollTo(4)
                }
            }
            return .unexpected
        }
        return nil
    }
    
    @MainActor
    func createEvent(value: ScrollViewProxy) async throws {
        guard Validate(value: value) == nil else {
            handleFailure()
            return
        }
        manager.status = .loading

        guard let user = session.user else {
            handleFailure()
            return
        }
        
        let event = try await manager.createEvent(user: user)
        
        guard let e = event else {
            handleFailure()
            return
        }
        
        session.events.append(e)
        await notificationsManager.setEventLocalNotification(e)
        dismiss()
    }
    
    var body: some View {
        ScrollViewReader { value in
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding(.horizontal)
                }.clipShape(Rectangle())
                
                Spacer()
                Spacer()
                
                Text("NEW EVENT")
                    .italic()
                    .fontWeight(.bold)
                
                Spacer()
                Spacer()
                Spacer()
                
            }
            .frame(height: 43)
            .overlay(Rectangle().frame(height: 0.2).foregroundColor(.foreground), alignment: .bottom)
            
            ScrollView(showsIndicators: false) {
                
                // MARK: - Top Options
                NewEventTopView(
                    showTypePicker: $showTypePicker,
                    showVisibilityPicker: $showVisibilityPicker,
                    eventType: $manager.type,
                    eventVisibility: $manager.visibility
                )
                
                // MARK: - Sport picker
                NewEventSportsPicker(sports: [], selectedSport: $manager.sports)
                    .padding(.horizontal)
                
                // MARK: - Organizers Picker
                VStack(alignment: .leading){
                    Text("Organizer(s)")
                        .font(.title3)
                        .bold()
                    Text("The clubs/organizations affiliated with this event")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    Button(action: { self.showOrganizersPicker.toggle() }) {
                        EventOrganizerView(organizers: $manager.organizers)
                            .modifier(InputField())
                    }
                    
                    Text("*required")
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $showOrganizersPicker) {
                    EventOrganizersPickerView(
                        selectedOrganizers: $manager.organizers
                    ).environment(session)
                }
                
                // MARK: - Title
                VStack(alignment: .leading){
                    Text("Title")
                        .font(.title3)
                        .bold()
                    Text("What to call the event")
                        .font(.subheadline)
                        .foregroundColor(validationStatus == .noTitle ? .red : .gray)
                    
                    TextField("", text: $manager.title)
                        .focused($titleFocus)
                        .padding(.leading)
                        .modifier(InputField())
                    
                    Text("*required")
                        .foregroundStyle(.gray)
                }
                .padding(.top)
                .padding(.horizontal)
                .id(1)
                
                // MARK: - Description
                VStack(alignment: .leading){
                    Text("Description")
                        .font(.title3)
                        .bold()
                    Text("Give details about the event")
                        .foregroundColor(validationStatus == .noDescription ? .red : .gray)
                        .font(.subheadline)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(Color.Background.secondary))
                            .frame(height: 100)
                        TextEditor(text: $manager.body)
                            .focused($descriptionFocus)
                            .frame(height: 95)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 5)
                    }
                    
                    Text("*required")
                        .foregroundStyle(.gray)
                }
                .padding(.top)
                .padding(.horizontal)
                .id(2)
                
                // MARK: - Venue Picker
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Venue(s)")
                                .font(.title3)
                                .bold()
                            Text("Location(s) of the event")
                                .font(.subheadline)
                                .foregroundColor(validationStatus == .noSelectedField ? .red : .gray)
                        }
                        
                        Spacer()
                        
                        
                        if hasSelectedVenue {
                            Button(action: { self.showVenuePicker.toggle() }) {
                                Text("Edit Venue(s)")
                                    .italic()
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2.5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.Background.secondary)
                                    }
                            }
                        }
                    }
                    
                    if hasSelectedVenue {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center) {
                            ForEach(manager.selectedVenueDescriptors, id: \.self) {
                                VenueDescriptorView(item: $0)
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(Color.Background.secondary))
                            .frame(height: 100)
                            .overlay {
                                Text("Pick a location")
                            }
                            .onTapGesture {
                                self.showVenuePicker.toggle()
                            }
                    }
                    
                    if !hasSelectedVenue {
                        Text("*required")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                .fullScreenCover(isPresented: $showVenuePicker) {
                    EventVenuePickerView(manager: manager)
                        .environment(session)
                }
                .id(3)
                
                // MARK: - Start Date/Time picker
                VStack(alignment: .leading){
                    Text("Start Date/Time")
                        .font(.title3)
                        .bold()
                    
                    Button(action: {
                        titleFocus = false
                        descriptionFocus = false
                        self.showStartTimePicker.toggle()
                    }) {
                        Text(startTimeString)
                            .modifier(InputField())
                    }
                }
                .padding()
                .sheet(isPresented: $showStartTimePicker, content: {
                    EventDatePickerView(eventTime: $manager.startDate)
                        .presentationDetents([.medium])
                })
                .id(4)
                
                // MARK: - End Date/Time picker
                VStack(alignment: .leading){
                    Text("End Date/Time")
                        .font(.title3)
                        .bold()
                    
                    Button(action: {
                        titleFocus = false
                        descriptionFocus = false
                        self.showStopTimePicker.toggle()
                    }) {
                        Text(stopTimeString)
                            .modifier(InputField())
                    }
                }
                .padding(.horizontal)
                .sheet(isPresented: $showStopTimePicker, content: {
                    EventDatePickerView(eventTime: $manager.endDate, startingPoint: manager.startDate.addingTimeInterval(30 * 60))
                        .presentationDetents([.medium])
                })
                
                // MARK: - Background Image picker
                EventImagePicker()
                    .padding([.top, .horizontal])
                    .environment(manager)
                
                HStack {
                    Spacer()
                    
                    Button(action: { showAdvancedSettings.toggle() }) {
                        HStack {
                            Text("Advanced Settings")
                                .fontWeight(.bold)
                            Image(systemName: "gearshape.fill")
                        }.padding(.all)
                    }
                }
                
                // MARK: - Action Button
                VStack(alignment: .center){
                    Button(action: { Task {
                        do {
                            try await createEvent(value: value)
                        } catch MediaUploadError.innapropriateContent {
                            self.showPostViolation.toggle()
                        } catch MediaUploadError.unexpected(let reason) {
                            log.error("Failed to create event: \(reason)")
                        }
                    } }) {
                        LoadingButton(text: "Create", width: 150, status: $manager.status)
                            .padding(.horizontal, 40)
                    }
                }.padding(.vertical, 50)
            }
            .onChange(of: manager.startDate) { _, v in
                if v > manager.endDate {
                    manager.endDate = manager.startDate.addingTimeInterval(30 * 60)
                }
            }
            .onChange(of: manager.endDate) { _, v in
                if v < manager.startDate {
                    manager.endDate = manager.startDate.addingTimeInterval(30 * 60)
                } else {
                    manager.endDate = v
                }
            }
            .task {
                guard let select = session.selectedGroup else {
                    return
                }
                if !manager.organizers.contains(where: { $0.id == select.id }) {
                    manager.organizers.append(select)
                }
            }
            .fullScreenCover(isPresented: $showAdvancedSettings) {
                NewEventAdvancedSettings(manager: manager)
            }
            .sheet(isPresented: $showPostViolation, content: {
                PostMediaViolation()
            })
        }.background(Color.Background.primary)
    }
}

#Preview {
    NewEvent(manager: NewEventManager())
        .environment(SessionStore())
}
