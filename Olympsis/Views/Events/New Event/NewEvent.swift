//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI
//import AlertToast

struct NewEvent: View {
    
    @State var manager: NewEventManager
    
    @State private var showToast: Bool = false
    
    @State private var showTypePicker: Bool = false
    @State private var showVisibilityPicker: Bool = false
    @State private var showSkillLevelPicker: Bool = false
    
    @State private var isEditing: Bool = false
    @State private var validationStatus: NEW_EVENT_ERROR?
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
        
        guard let id = try await manager.createEvent(user: user),
            let url = URL(string: "olympsis://events?id=\(id)") else {
            log.error("Failed to create event. No ID or failed to construct URL.")
            dismiss()
            return
        }
        openURL(url)
        dismiss()
    }
    
    func handleEventCreation(_ value: ScrollViewProxy) {
        Task {
            guard manager.status != .loading else { return }
            
            do {
                try await createEvent(value: value)
            } catch MediaUploadError.innapropriateContent {
                self.showPostViolation.toggle()
            } catch {
                showToast.toggle()
            }
        }
    }
    
    func removeSelectedVenue(_ descriptor: VenueDescriptor) {
        manager.selectedVenueDescriptors.removeAll(where: { $0 == descriptor })
        manager.selectedVenues.removeAll(where: { $0.name == descriptor.name })
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { value in
                Form {
                    // MARK: - Title and sports selection
                    Section {
                        NewEventTopView(
                            showTypePicker: $showTypePicker,
                            showVisibilityPicker: $showVisibilityPicker,
                            eventType: $manager.type,
                            eventVisibility: $manager.visibility
                        )
                        
                        VStack(alignment: .leading){
                            TextField("Event Title", text: $manager.title)
                                .focused($titleFocus)
                                .padding(.leading)
                                .modifier(InputFieldModifier())
                        }
                        .id(1)
                        
                        NewEventSportsPicker(sports: session.sports, selectedSports: $manager.selectedSports)
                    }
                    
                    // MARK: - Organizers Picker
                    Section {
                        VStack(alignment: .leading){
                            HStack {
                                NewEventOrganizers(manager: manager)
                                Spacer()
                            }
                        }
                        .fullScreenCover(isPresented: $showOrganizersPicker) {
                            EventOrganizersPickerView(
                                selectedOrganizers: $manager.organizers
                            ).environment(session)
                        }
                    }
                    
                    // MARK: - Event start/stop dates
                    Section {
                        VStack(alignment: .leading){
                            Text(String(localized: "new-event-start-time-title", table: "Events"))
                                .font(.headline)
                                .bold()
                            
                            Button(action: {
                                titleFocus = false
                                descriptionFocus = false
                                self.showStartTimePicker.toggle()
                            }) {
                                Text(startTimeString)
                                    .modifier(InputFieldModifier())
                            }
                        }
                        .sheet(isPresented: $showStartTimePicker, content: {
                            EventDatePickerView(eventTime: $manager.startDate)
                                .presentationDetents([.medium])
                        })
                        .id(2)
                        
                        
                        VStack(alignment: .leading){
                            Text(String(localized: "new-event-stop-time-title", table: "Events"))
                                .font(.headline)
                                .bold()
                            
                            Button(action: {
                                titleFocus = false
                                descriptionFocus = false
                                self.showStopTimePicker.toggle()
                            }) {
                                Text(stopTimeString)
                                    .modifier(InputFieldModifier())
                            }
                        }
                        .sheet(isPresented: $showStopTimePicker, content: {
                            EventDatePickerView(eventTime: $manager.endDate, startingPoint: manager.startDate.addingTimeInterval(30 * 60))
                                .presentationDetents([.medium])
                        })
                        .id(3)
                    }
                    
                    // MARK: - Description
                    Section {
                        VStack(alignment: .leading){
                            Text(String(localized: "new-event-description-title", table: "Events"))
                                .font(.headline)
                                .bold()
                            Text(String(localized: "new-event-description-sub-title", table: "Events"))
                                .foregroundColor(validationStatus == .noDescription ? .red : .gray)
                                .font(.subheadline)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.Background.secondary)
                                    .frame(height: 100)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                    }
                                TextEditor(text: $manager.body)
                                    .focused($descriptionFocus)
                                    .frame(height: 95)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 5)
                            }
                        }.id(4)
                    }
                    
                    // MARK: - Venue picker
                    Section {
                        VenuePickerButton(validationStatus: $validationStatus)
                            .environment(session)
                            .environment(manager)
                            .id(5)
                    }
                    
                    // MARK: - Image picker
                    Section {
                        NewEventImagePicker()
                            .environment(manager)
                    }
                    
                    // MARK: - Tags and advanced settings
                    Section {
                        NewEventTagsPicker(tags: session.tags, selectedTags: $manager.selectedTags)
                        
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: NewEventAdvancedSettings().environment(manager)) {
                                Text(String(localized: "advanced-settings-title", table: "Events"))
                                    .fontWeight(.bold)
                                Image(systemName: "gearshape.fill")
                            }
                        }
                    }
                    
                    // MARK: - Action Button
                    VStack(alignment: .center){
                        Button(action: { handleEventCreation(value) }) {
                            LoadingButton(text: String(localized: "new-event-create-text", table: "Events"), width: 150, status: $manager.status)
                        }
                    }
                    .listRowBackground(Color.clear)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Text(String(localized: "new-event-view-title", table: "Events"))
                                .italic()
                                .textCase(.uppercase)
                                .fontWeight(.bold)
                        }.sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Text(String(localized: "new-event-view-title", table: "Events"))
                                .italic()
                                .textCase(.uppercase)
                                .fontWeight(.bold)
                        }
                    }
                
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
                .sheet(isPresented: $showPostViolation, content: {
                    PostMediaViolation()
                })
                .task {
                    guard let select = session.groupsManager.selected else {
                        return
                    }
                    if !manager.organizers.contains(where: { $0.id == select.id }) {
                        manager.organizers.append(select)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewEvent(manager: NewEventManager())
            .environment(SessionStore())
    }
}
