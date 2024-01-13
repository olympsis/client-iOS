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
    enum NEW_EVENT_ERROR: Error {
        case unexpected
        case noTitle
        case noDescription
    }
    
    enum SkillLevel: String, CaseIterable {
        case any = "Any Level"
        case beginner   = "Beginner"
        case amateur    = "Amateur"
        case expert     = "Expert"
    }
    
    func getSkillRaw(for skill: SkillLevel) -> Int {
        switch skill {
        case .any:
            return 0
        case .beginner:
            return 1
        case .amateur:
            return 2
        case .expert:
            return 3
        }
    }
    
    @State var eventField: Field
    
    @State private var isEditing:               Bool = false
    
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var eventStartTime:          Date = Date()
    @State private var eventStopTime:           Date = Date().addingTimeInterval(30 * 60)
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              SPORT = .soccer
    @State private var eventLevel:              Int    = 0
    @State private var eventMaxParticipants:    Double = 0
    @State private var eventMinParticipants:    Double = 0
    @State private var eventVisibility:         EVENT_VISIBILITY_TYPES = .Public
    @State private var eventSkilLevel:          EVENT_SKILL_LEVELS = .All
    @State private var status:                  LOADING_STATE = .pending
    @State private var validationStatus:        NEW_EVENT_ERROR = .unexpected
    @State private var eventOrganizers: [GroupSelection] = [GroupSelection]()
    
    @State private var hasEndTime: Bool = false
    @State private var showFieldPicker: Bool = false
    @State private var showSportsPicker: Bool = false
    @State private var showCompletedToast: Bool = false
    @State private var showStartTimePicker: Bool = false
    @State private var showStopTimePicker: Bool = false
    @State private var showOrganizersPicker: Bool = false
    @State private var showVisibilityPicker: Bool = false
    @State private var showSkillLevelPicker: Bool = false
    
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) var dismiss
    
    var log = Logger(subsystem: "com.josephlabs.olympsis", category: "new_event_view")
    
    var selectedField: String {
        return eventField.id
    }
    
    var selectedImage: String {
        guard eventImageURL != "" else {
            return eventSport.Images()[Int.random(in: 0...eventSport.Images().count-1)]
        }
        return eventImageURL
    }
    
    // filters all of the clubs and the group selections that might not have a club
    // force returns a club since it should exist from the filter operation
    var selectedClubs: [Club] {
        return eventOrganizers.filter { $0.type == GROUP_TYPE.Club.rawValue && $0.club != nil }.map {
            return $0.club!
        }
    }
    
    // filters all of the organizations and the group selections that might not have a organization
    // force returns a organization since it should exist from the filter operation
    var selectedOrganizations: [Organization] {
        return eventOrganizers.filter { $0.type == GROUP_TYPE.Organization.rawValue && $0.organization != nil }.map {
            return $0.organization!
        }
    }
    
    var setStartTime: Int {
        return Int(eventStartTime.timeIntervalSince1970)
    }
    
    var setStopTime: Int {
        return Int(eventStopTime.timeIntervalSince1970)
    }
    
    var startTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - hh:mm a"
        return dateFormatter.string(from: eventStartTime)
    }
    
    var stopTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - hh:mm a"
        return dateFormatter.string(from: eventStopTime)
    }
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func handleSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    func Validate() -> NEW_EVENT_ERROR? {
        if eventTitle == "" {
            validationStatus = .noTitle
            return .noTitle
        } else if eventBody == "" {
            validationStatus = .noDescription
            return .noDescription
        }
        validationStatus = .unexpected
        return nil
    }
    
    func CreateEvent() async {
        let res = Validate()
        if let _ = res {
            handleFailure()
            return
        }
        status = .loading
        guard let user = session.user,
              let uuid = user.uuid else {
            handleFailure()
            return
        }
        
        let organizers = eventOrganizers.map {
            if $0.type == GROUP_TYPE.Club.rawValue {
                return Organizer(type: $0.type, id: $0.club?.id ?? "")
            } else {
                return Organizer(type: $0.type, id: $0.organization?.id ?? "")
            }
        }
        
        let event = Event(id: nil, type: "pickup", poster: uuid, organizers: organizers, field: FieldDescriptor(type: "internal", id: eventField.id, location: nil), imageURL: selectedImage, title: eventTitle, body: eventBody, sport: eventSport.rawValue, level: eventLevel, startTime: setStartTime, stopTime: setStopTime, actualStopTime: nil, minParticipants: Int(eventMinParticipants), maxParticipants: Int(eventMaxParticipants), participants: nil, visibility: "public", data: nil, createdAt: nil)

        let resp = await session.eventObserver.createEvent(event: event)
        guard let newEvent = resp,
              let userData = session.user else {
            log.error("Failed to create event")
            handleFailure()
            return
        }
        
        newEvent.participants?[0].data = user
        await MainActor.run {
            newEvent.data = EventData(poster: userData, field: eventField, clubs: selectedClubs, organizations: selectedOrganizations)
            session.events.append(newEvent)
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                ScrollView(showsIndicators: false) {
                    
                    // MARK: - Top Options
                    NewEventTopView(showVisibilityPicker: $showVisibilityPicker, showSkillLevelPicker: $showSkillLevelPicker, eventSkilLevel: $eventSkilLevel, eventVisibility: $eventVisibility)
                    
                    // MARK: - Title
                    VStack(alignment: .leading){
                        Text("Title")
                            .font(.title3)
                            .bold()
                        Text("What to call the event")
                            .font(.subheadline)
                            .foregroundColor(validationStatus == .noTitle ? .red : .gray)
                        
                        TextField("", text: $eventTitle)
                            .padding(.leading)
                            .modifier(InputField())
                    }.padding(.horizontal)

                    // MARK: - Description
                    VStack(alignment: .leading){
                        Text("Description")
                            .font(.title3)
                            .bold()
                        Text("Give details about the event")
                            .foregroundColor(validationStatus == .noDescription ? .red : .gray)
                            .font(.subheadline)
                        ZStack {
                            Rectangle()
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color("color-prime"))
                                .frame(height: 100)
                            TextEditor(text: $eventBody)
                                .frame(height: 95)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 5)
                        }
                    }.padding(.top)
                    .padding(.horizontal)
                    
                    // MARK: - Sports picker
                    VStack(alignment: .leading){
                        Text("Sport")
                            .font(.title3)
                            .bold()
                        Text("The sport you're going to play")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Picker(selection: $eventSport, label: Text("")) {
                            ForEach(SPORT.allCases, id: \.rawValue) { sport in
                                Text(sport.rawValue.prefix(1).capitalized + sport.rawValue.dropFirst()).tag(sport)
                            }
                        }.modifier(InputField())
                            
                    }.padding(.top)
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
                            ZStack {
                                Rectangle()
                                    .stroke(lineWidth: 1)
                                    .modifier(InputField())
                                EventOrganizerView(organizers: $eventOrganizers)
                            }
                        }
                    }.padding(.vertical)
                        .padding(.horizontal)
                    
                    // MARK: - Field Picker
                    VStack(alignment: .leading){
                        Text("Field")
                            .font(.title3)
                            .bold()
                        Text("Location of the event")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Button(action: { self.showFieldPicker.toggle() }) {
                            ZStack {
                                Rectangle()
                                    .stroke(lineWidth: 1)
                                    .modifier(InputField())
                                Text(eventField.name)
                            }
                        }
                    }.padding(.horizontal)
                    
                    // MARK: - Start Date/Time picker
                    VStack(alignment: .leading){
                        Text("Start Date/Time")
                            .font(.title3)
                            .bold()
                        
                        Button(action: { self.showStartTimePicker.toggle() }) {
                            ZStack {
                                Rectangle()
                                    .stroke(lineWidth: 1)
                                    .modifier(InputField())
                                Text(startTimeString)
                            }
                        }
                    }.padding()
                    
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
                            Button(action: { self.showStopTimePicker.toggle() }) {
                                ZStack {
                                    Rectangle()
                                        .stroke(lineWidth: 1)
                                        .modifier(InputField())
                                    Text(stopTimeString)
                                }
                            }
                        }
                    }.padding(.horizontal)
                    
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
                                value: $eventMinParticipants,
                                in: 0...100,
                                step: 1.0,
                                onEditingChanged: { editing in
                                    isEditing = editing
                                }).padding(.leading)
                                .padding(.trailing)
                            
                            Text("\(Int(eventMinParticipants))")
                                .foregroundColor(isEditing ? .red : Color("color-prime"))
                            Stepper("", value: $eventMinParticipants, in: 0...100)
                                .padding(.trailing)
                        }.modifier(InputField())
                        
                    }.padding(.top)
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
                                value: $eventMaxParticipants,
                                in: 0...1000,
                                step: 5.0,
                                onEditingChanged: { editing in
                                    isEditing = editing
                                }).padding(.leading)
                                .padding(.trailing)
                            
                            Text("\(Int(eventMaxParticipants))")
                                .foregroundColor(isEditing ? .red : Color("color-prime"))
                            Stepper("", value: $eventMaxParticipants, in: 0...1000)
                                .padding(.trailing)
                        }.modifier(InputField())
                        
                    }.padding(.top)
                        .padding(.horizontal)
                    
                    // MARK: - Background Image picker
                    VStack(alignment: .leading){
                        Text("Event Image")
                            .font(.title3)
                            .bold()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(eventSport.Images(), id: \.self) { image in
                                    Button(action:{ self.eventImageURL = image }) {
                                        ZStack(alignment: .bottomTrailing){
                                            Image(image)
                                                .resizable()
                                                .frame(width: 100, height: 150)
                                            if eventImageURL == image {
                                                Image(systemName: "circle.fill")
                                                    .foregroundColor(Color("color-secnd"))
                                                    .padding(.bottom, 5)
                                                    .padding(.trailing, 5)
                                                
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(Color("color-secnd"))
                                                    .padding(.bottom, 5)
                                                    .padding(.trailing, 5)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }.padding(.top)
                        .padding(.horizontal)
                    
                    // MARK: - Action Button
                    VStack(alignment: .center){
                        Button(action: { Task { await CreateEvent() } }) {
                            LoadingButton(text: "Create", width: 150, status: $status)
                                .padding(.horizontal, 40)
                        }
                    }.padding(.vertical, 50)
                }
                .fullScreenCover(isPresented: $showOrganizersPicker) {
                    EventOrganizersPickerView(selectedOrganizers: $eventOrganizers, organizers: session.groups, clubs: session.clubs, organizations: session.orgs)
                }
                .fullScreenCover(isPresented: $showFieldPicker) {
                    EventFieldPickerView(selectedField: $eventField, fields: session.fields)
                }
                .sheet(isPresented: $showStartTimePicker, content: {
                    EventDatePickerView(eventTime: $eventStartTime)
                        .presentationDetents([.medium])
                })
                .sheet(isPresented: $showStopTimePicker, content: {
                    EventDatePickerView(eventTime: $eventStopTime, startingPoint: eventStartTime.addingTimeInterval(30 * 60))
                        .presentationDetents([.medium])
                })
                .onAppear {
                    guard let select = session.selectedGroup else {
                        return
                    }
                    eventOrganizers.append(select)
                }
                .onChange(of: eventStartTime) { v in
                    if hasEndTime {
                        if v > eventStopTime {
                            eventStopTime = eventStartTime.addingTimeInterval(30 * 60)
                        }
                    }
                }
                .onChange(of: eventStopTime) { v in
                    if v < eventStartTime {
                        eventStopTime = eventStartTime.addingTimeInterval(30 * 60)
                    } else {
                        eventStopTime = v
                    }
                }
            }.navigationTitle("Pick Up")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewPickUpEvent(eventField: FIELDS[0])
        .environmentObject(SessionStore())
}
