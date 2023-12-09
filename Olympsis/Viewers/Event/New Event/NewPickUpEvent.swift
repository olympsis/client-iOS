//
//  NewPickUpEvent.swift
//  Olympsis
//
//  Created by Joel on 11/13/23.
//

import os
import SwiftUI

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
    
    @State private var isEditing:               Bool = false
    @State private var showCompletedToast:      Bool = false
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var fieldIndex:              Int = 0
    @State private var clubIndex:               Int = 0
    @State private var eventStartTime:          Date = Date()
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              SPORT = .soccer
    @State private var eventLevel:              Int    = 0
    @State private var eventMaxParticipants:    Double = 0
    @State private var eventMinParticipants:    Double = 0
    @State private var status:                  LOADING_STATE = .pending
    @State private var validationStatus:        NEW_EVENT_ERROR = .unexpected
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var log = Logger(subsystem: "com.josephlabs.olympsis", category: "new_event_view")
    
    var selectedClub: String {
        guard let id = session.clubs[clubIndex].id else {
            return ""
        }
        return id
    }
    
    var selectedField: String {
        return session.fields[fieldIndex].id
    }
    
    var selectedImage: String {
        guard eventImageURL != "" else {
            return eventSport.Images()[Int.random(in: 0...eventSport.Images().count-1)]
        }
        return eventImageURL
    }
    
    var setStartTime: Int64 {
        return Int64(eventStartTime.timeIntervalSince1970)
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
            return
        }
        status = .loading
        guard let user = session.user,
              let uuid = user.uuid else {
            return
        }
        let participant = Participant(uuid: uuid, status: "yes", createdAt: Int64(Date().timeIntervalSince1970))
        let event = Event(id: nil, type: "pickup", poster: uuid, clubID: selectedClub, fieldID: selectedField, imageURL: selectedImage, title: eventTitle, body: eventBody, sport: eventSport.rawValue, level: eventLevel,startTime: setStartTime,minParticipants: Int(eventMinParticipants), maxParticipants: Int(eventMaxParticipants), participants: [participant], visibility: "public", data: nil, createdAt: nil)
        
        let resp = await session.eventObserver.createEvent(event: event)
        guard let newEvent = resp,
              let userData = session.user else {
            log.error("failed to create event")
            return
        }
        newEvent.participants?[0].data = user
        await MainActor.run {
            newEvent.data = EventData(poster: userData, club: session.clubs[clubIndex], field: session.fields[fieldIndex])
            session.events.append(newEvent)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            ScrollView(showsIndicators: false) {
                HStack {
                    Text("Create an Event")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)
                    Spacer()
                }.padding(.vertical, 30)
                
                // MARK: - Title
                VStack(alignment: .leading){
                    Text("Title")
                        .font(.title3)
                        .bold()
                    Text("What to call the event")
                        .font(.subheadline)
                        .foregroundColor(validationStatus == .noTitle ? .red : .gray)
                    
                    TextField("title", text: $eventTitle)
                        .padding(.leading)
                        .modifier(MenuButton())
                }
                
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
                            Text(sport.rawValue).tag(sport)
                        }
                    }.modifier(MenuButton())
                }.padding(.top)
                
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
                            .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                            .frame(height: 100)
                        TextEditor(text: $eventBody)
                            .frame(height: 95)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 5)
                    }
                }.padding(.horizontal)
                
                // MARK: - Club/Field picker
                VStack(alignment: .leading){
                    VStack(alignment: .leading){
                        Text("Organizer")
                            .font(.title3)
                            .bold()
                        Text("The club/organization affiliated with the event")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Picker(selection: $clubIndex, label: Text("")) {
                            ForEach(Array(session.clubs.enumerated()), id: \.1.id) { index, club in
                                Text(club.name ?? "error").tag(index)
                            }
                        }.modifier(MenuButton())
                    }.padding(.vertical)
                    
                    Text("Field")
                        .font(.title3)
                        .bold()
                    Text("Location of the event")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    Picker(selection: $fieldIndex, label: Text("")) {
                        ForEach(Array(session.fields.enumerated()), id: \.1.id) { index, field in
                            Text(field.name).tag(index)
                        }
                    }.modifier(MenuButton())
                }.padding(.horizontal)
                
                
                // MARK: - Date/Time picker
                VStack(alignment: .leading){
                    Text("Start Date/Time")
                        .font(.title3)
                        .bold()
                    DatePicker("Date", selection: $eventStartTime, in: Date()...)
                        .datePickerStyle(.graphical)
                }
                .padding(.vertical)
                .padding(.horizontal)
                
                
                // MARK: - Skill Level picker
                VStack(alignment: .leading){
                    Text("Skill Level")
                        .font(.title3)
                        .bold()
                    Text("Participants expected skill level")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Picker(selection: $eventLevel, label: Text("")) {
                        ForEach(SkillLevel.allCases, id: \.rawValue) { skill in
                            Text(skill.rawValue).tag(getSkillRaw(for: skill))
                        }
                    }.modifier(MenuButton())
                }
                .padding(.horizontal)
                
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
                        Spacer()
                        Text("\(Int(eventMinParticipants))")
                            .foregroundColor(isEditing ? .red : Color("color-prime"))
                        Stepper("", value: $eventMinParticipants, in: 0...100)
                            .padding(.trailing)
                    }.modifier(MenuButton())
                    
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
                        Spacer()
                        Text("\(Int(eventMaxParticipants))")
                            .foregroundColor(isEditing ? .red : Color("color-prime"))
                        Stepper("", value: $eventMaxParticipants, in: 0...1000)
                            .padding(.trailing)
                    }.modifier(MenuButton())
                    
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
                }.padding(.top, 50)
            }
        }
    }
}

#Preview {
    NewPickUpEvent()
        .environmentObject(SessionStore())
}
