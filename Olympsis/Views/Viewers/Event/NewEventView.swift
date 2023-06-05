//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI
import AlertToast

struct NewEventView: View {
    
    enum NEW_EVENT_ERROR: Error {
        case unexpected
        case noTitle
        case noDescription
    }
    
    enum SkillLevel: String, CaseIterable {
        case beginner   = "Beginner"
        case amateur    = "Amateur"
        case expert     = "Expert"
    }
    
    func getSkillRaw(for skill: SkillLevel) -> Int {
        switch skill {
        case .beginner:
            return 1
        case .amateur:
            return 2
        case .expert:
            return 3
        }
    }
    
    @State var fields: [Field]
    @State private var isEditing:               Bool = false
    @State private var showCompletedToast:      Bool = false
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var fieldIndex:              Int = 0
    @State private var clubIndex:               Int = 0
    @State private var eventStartTime:          Date = Date()
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              SPORT = .soccer
    @State private var eventLevel:              Int    = 1
    @State private var eventMaxParticipants:    Double = 1
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
        return fields[fieldIndex].id
    }
    
    var selectedImage: String {
        guard eventImageURL != "" else {
            return eventImageURL
        }
        return eventSport.Images()[Int.random(in: 0...eventSport.Images().count)]
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
        let event = Event(id: nil, poster: uuid, clubID: selectedClub, fieldID: selectedField, imageURL: selectedImage, title: eventTitle, body: eventBody, sport: eventSport.rawValue, level: eventLevel,startTime: setStartTime, maxParticipants: Int(eventMaxParticipants), likes: nil, visibility: "public", data: nil, createdAt: nil)
        
        let resp = await session.eventObserver.createEvent(event: event)
        if resp {
            log.error("failed to create event")
        }
        
        // fetch new events
        guard let location = session.locationManager.location else {
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        await session.getNearbyData(location: location)
        self.presentationMode.wrappedValue.dismiss()
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
                }.padding(.bottom, 30)
                    .padding(.top, 30)
                
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
                            .tint(Color("primary-color"))
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
                            Text(sport.Icon() + " " + sport.rawValue).tag(sport)
                        }
                    }.modifier(MenuButton())
                        .tint(Color("primary-color"))
                    
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
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
                            .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                            .frame(height: 100)
                        TextEditor(text: $eventBody)
                            .frame(height: 95)
                            .scrollContentBackground(.hidden)
                            .tint(Color("primary-color"))
                            .padding(.leading, 5)
                    }
                }.frame(width: SCREEN_WIDTH-25)
                
                // MARK: - Club/Field picker
                VStack(alignment: .leading){
                    // MARK: - Field picker
                    VStack(alignment: .leading){
                        Text("Club")
                            .font(.title3)
                            .bold()
                        Text("The club affiliated with the event")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Picker(selection: $clubIndex, label: Text("")) {
                            ForEach(Array(session.clubs.enumerated()), id: \.1.id) { index, club in
                                Text(club.name ?? "error").tag(index)
                            }
                        }.modifier(MenuButton())
                            .tint(Color("primary-color"))
                    }.padding(.top)

                        .padding(.bottom)
                    Text("Field")
                        .font(.title3)
                        .bold()
                    Text("Location of the event")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    Picker(selection: $fieldIndex, label: Text("")) {
                        ForEach(Array(fields.enumerated()), id: \.1.id) { index, field in
                            Text(field.name).tag(index)
                        }
                    }.modifier(MenuButton())
                        .tint(Color("primary-color"))
                    
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-25)
                
                // MARK: - Date/Time picker
                VStack(alignment: .leading){
                    Text("Start Date/Time")
                        .font(.title3)
                        .bold()
                    DatePicker("", selection: $eventStartTime, in: Date()...)
                        .datePickerStyle(.graphical)
                        .tint(Color("primary-color"))

                }.padding(.top, 30)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Skill Level picker
                VStack(alignment: .leading){
                    Text("Skill Level")
                        .font(.title3)
                        .bold()
                    Text("Participants expected experience")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Picker(selection: $eventLevel, label: Text("")) {
                        ForEach(SkillLevel.allCases, id: \.rawValue) { skill in
                            Text(skill.rawValue).tag(getSkillRaw(for: skill))
                        }
                    }.modifier(MenuButton())
                        .tint(Color("primary-color"))
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
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
                                in: 1...100,
                                step: 1.0,
                                onEditingChanged: { editing in
                                isEditing = editing
                                }).padding(.leading)
                                .padding(.trailing)
                            Spacer()
                            Text("\(Int(eventMaxParticipants))")
                                .foregroundColor(isEditing ? .red : Color("primary-color"))
                            Stepper("", value: $eventMaxParticipants, in: 1...100)
                                .padding(.trailing)
                        }.modifier(MenuButton())
                    
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Background Image picker
                VStack(alignment: .leading){
                    Text("Event Image")
                        .font(.title3)
                        .bold()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(eventSport.Images(), id: \.self) { image in
                                Button(action:{self.eventImageURL = image}) {
                                    ZStack(alignment: .bottomTrailing){
                                        Image(image)
                                            .resizable()
                                            .frame(width: 100, height: 150)
                                        .cornerRadius(10)
                                        if eventImageURL == image {
                                            Image(systemName: "circle.fill")
                                                .foregroundColor(Color("secondary-color"))
                                                .padding(.bottom, 5)
                                                .padding(.trailing, 5)
                                                
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(Color("secondary-color"))
                                                .padding(.bottom, 5)
                                                .padding(.trailing, 5)
                                                .fontWeight(.bold)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.frame(width: SCREEN_WIDTH-50)
                    .padding(.top)
                // MARK: - Action Button
                VStack(alignment: .center){
                    Button(action: { Task { await CreateEvent() } }) {
                        LoadingButton(text: "Create", width: 150, status: $status)
                    }
                }.padding(.top, 50)
            }.frame(width: SCREEN_WIDTH)
        }.task{
            
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView(fields: FIELDS)
            .environmentObject(SessionStore())
    }
}
