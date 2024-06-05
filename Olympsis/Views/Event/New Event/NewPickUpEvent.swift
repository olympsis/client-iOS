//
//  NewPickUpEvent.swift
//  Olympsis
//
//  Created by Joel on 11/13/23.
//

import os
import SwiftUI

/// This view has all of the information needed to create an pick up event in Olympsis.
struct NewPickUpEvent: View {
    
    @State private var isEditing: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var validationStatus: NEW_EVENT_ERROR = .unexpected
    
    @State private var hasEndTime: Bool = false
    @State private var showFieldPicker: Bool = false
    @State private var showSportsPicker: Bool = false
    @State private var showCompletedToast: Bool = false
    @State private var showStartTimePicker: Bool = false
    @State private var showStopTimePicker: Bool = false
    @State private var showOrganizersPicker: Bool = false
    @State private var showVisibilityPicker: Bool = false
    @State private var showSkillLevelPicker: Bool = false
    
    @FocusState private var titleFocus: Bool
    @FocusState private var descriptionFocus: Bool
    
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var manager: NewEventManager
    @Environment(\.dismiss) var dismiss
    
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "new_event_view")
    
    private var fieldID: String {
        guard let selectedField = manager.field else {
            return ""
        }
        return selectedField.id
    }
    
    private var fieldName: String {
        guard let selectedField = manager.field else {
            return ""
        }
        return selectedField.name
    }
    
    private var selectedImage: String {
        guard let img = manager.image else {
            return manager.sport.images()[Int.random(in: 0...manager.sport.images().count-1)]
        }
        return img
    }
    
    // filters all of the clubs and the group selections that might not have a club
    // force returns a club since it should exist from the filter operation
    private var selectedClubs: [Club] {
        return manager.organizers.filter { $0.type == GROUP_TYPE.Club && $0.club != nil }.map {
            return $0.club!
        }
    }
    
    // filters all of the organizations and the group selections that might not have a organization
    // force returns a organization since it should exist from the filter operation
    private var selectedOrganizations: [Organization] {
        return manager.organizers.filter { $0.type == GROUP_TYPE.Organization && $0.organization != nil }.map {
            return $0.organization!
        }
    }
    
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
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    private func handleSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    func Validate(value: ScrollViewProxy) -> NEW_EVENT_ERROR? {
        // make sure we have a title
        guard manager.title != "" else {
            Task { @MainActor in
                validationStatus = .noTitle
                withAnimation {
                    value.scrollTo(1)
                }
            }
            return .noTitle
        }
        // make sure we have a description
        guard manager.body != "" else {
            Task { @MainActor in
                validationStatus = .noDescription
                withAnimation {
                    value.scrollTo(2)
                }
            }
            return .noDescription
        }
        // make sure we have a selected field
        guard manager.field != nil else {
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
    
    func CreateEvent(value: ScrollViewProxy) async {
        guard Validate(value: value) == nil else {
            handleFailure()
            return
        }
        status = .loading

        guard let dao = manager.generateNewEventData() else {
            log.error("Failed to generate new event data")
            handleFailure()
            return
        }
        guard let id = await session.eventObserver.createEvent(event: dao) else {
            handleFailure()
            return
        }
        
        guard let user = session.user,
              let event = manager.generateNewEvent(id: id, dao: dao, user: user) else {
            return
        }
        
        await MainActor.run {
            session.events.append(event)
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                ScrollViewReader { value in
                    ScrollView(showsIndicators: false) {
                        
                        // MARK: - Top Options
                        NewEventTopView(showVisibilityPicker: $showVisibilityPicker, showSkillLevelPicker: $showSkillLevelPicker, eventSkilLevel: $manager.skillLevel, eventVisibility: $manager.visibility)
                        
                        // MARK: - Sport picker
                        NewEventSportsPicker(selectedSport: $manager.sport)
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
                        }
                        .padding(.horizontal)
                        .fullScreenCover(isPresented: $showOrganizersPicker) {
                            EventOrganizersPickerView(selectedOrganizers: $manager.organizers, organizers: session.groups, clubs: session.clubs, organizations: session.orgs)
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
                                    .foregroundColor(Color("background"))
                                    .frame(height: 100)
                                TextEditor(text: $manager.body)
                                    .focused($descriptionFocus)
                                    .frame(height: 95)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 5)
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .id(2)
                        
                        // MARK: - Venue Picker
                        VStack(alignment: .leading){
                            Text("Venue(s)")
                                .font(.title3)
                                .bold()
                            Text("Location(s) of the event")
                                .font(.subheadline)
                                .foregroundColor(validationStatus == .noSelectedField ? .red : .gray)
                            NavigationLink(destination: EventVenuePickerView().environmentObject(manager).environmentObject(session)) {
                                if hasSelectedVenue {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center) {
                                        ForEach(manager.selectedVenueDescriptors, id: \.self) {
                                            VenueDescriptorView(item: $0)
                                        }
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color("background"))
                                        .frame(height: 100)
                                        .overlay {
                                            Text("Pick a location")
                                        }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .fullScreenCover(isPresented: $showFieldPicker) {
                            EventVenuePickerView()
                                .environmentObject(manager)
                                .environmentObject(session)
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
                            HStack {
                                Text("End Date/Time")
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                                
                                withAnimation(.easeInOut(duration: 10)) {
                                    Toggle(isOn: $hasEndTime) {}
                                }
                            }
                            
                            if hasEndTime {
                                Button(action: {
                                    titleFocus = false
                                    descriptionFocus = false
                                    self.showStopTimePicker.toggle()
                                }) {
                                    Text(stopTimeString)
                                        .modifier(InputField())
                                }
                            }
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showStopTimePicker, content: {
                            EventDatePickerView(eventTime: $manager.endDate, startingPoint: manager.startDate.addingTimeInterval(30 * 60))
                                .presentationDetents([.medium])
                        })
                        
                        // MARK: - Min Participants slider
                        VStack(alignment: .leading){
                            Text("Min Participants")
                                .font(.title3)
                                .bold()
                            Text("The minimum number of participants")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            
                            HStack {
                                Slider(
                                    value: $manager.minParticipants,
                                    in: 0...100,
                                    step: 1.0,
                                    onEditingChanged: { editing in
                                        isEditing = editing
                                    }).padding(.horizontal)
                                
                                Text("\(Int(manager.minParticipants))")
                                    .foregroundColor(isEditing ? .red : Color("color-prime"))
                                Stepper("", value: $manager.minParticipants, in: 0...100)
                                    .padding(.trailing)
                            }.modifier(InputField())
                            
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        
                        // MARK: - Max Participants slider
                        VStack(alignment: .leading){
                            Text("Max Participants")
                                .font(.title3)
                                .bold()
                            Text("Limit the headcount")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            
                            HStack {
                                Slider(
                                    value: $manager.maxParticipants,
                                    in: 0...1000,
                                    step: 5.0,
                                    onEditingChanged: { editing in
                                        isEditing = editing
                                    }).padding(.horizontal)
                                
                                Text("\(Int(manager.maxParticipants))")
                                    .foregroundColor(isEditing ? .red : Color("color-prime"))
                                Stepper("", value: $manager.maxParticipants, in: 0...1000)
                                    .padding(.trailing)
                            }.modifier(InputField())
                            
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        
                        // MARK: - Background Image picker
                        EventImagePicker()
                            .padding([.top, .horizontal])
                            .environmentObject(manager)
                        
                        // MARK: - Action Button
                        VStack(alignment: .center){
                            Button(action: { Task { await CreateEvent(value: value) } }) {
                                LoadingButton(text: "Create", width: 150, status: $status)
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
                        manager.organizers.append(select)
                    }
                }
            }.navigationTitle("Pick Up")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewPickUpEvent()
        .environmentObject(SessionStore())
        .environmentObject(NewEventManager())
}
