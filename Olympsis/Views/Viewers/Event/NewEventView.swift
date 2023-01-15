//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import SwiftUI
import AlertToast

struct NewEventView: View {
    
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
    
    @State private var isEditing:               Bool = false
    @State private var showCompletedToast:      Bool = false
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var eventFieldId:            String = ""
    @State private var eventClubId:             String = ""
    @State private var eventStartTime:          Date = Date()
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              SPORTS = .soccer
    @State private var eventLevel:              Int    = 1
    @State private var eventMaxParticipants:    Double = 0
    @State private var status:                  LOADING_STATE = .pending
    
    @StateObject private var eventObserver =  EventObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func CreateEvent() async {
        status = .loading
        let dao = EventDao(title: eventTitle, body: eventBody, clubId: eventClubId, fieldId: eventFieldId, imageURL: eventImageURL, sport: eventSport.rawValue, startTime: Int(eventStartTime.timeIntervalSince1970), maxParticipants: Int(eventMaxParticipants), level: eventLevel, status: "pending")
        let resp = await eventObserver.createEvent(dao: dao)
        if var r = resp {
            if let usr = session.user {
                r.ownerData = UserPeek(firstName: usr.firstName, lastName: usr.lastName, username: usr.username, imageURL: usr.imageURL ?? "", bio: usr.bio ?? "", sports: usr.sports ?? [String]())
            }
            status = .success
            await MainActor.run {
                session.events.append(r)
            }
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
                }.padding(.bottom, 30)
                    .padding(.top, 30)
                
                // MARK: - Title
                VStack(alignment: .leading){
                    Text("Title")
                        .font(.title3)
                        .bold()
                    Text("What to call the event")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
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
                    
                    Picker(selection: $eventSport, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                        ForEach(SPORTS.allCases, id: \.rawValue) { sport in
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
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                            .frame(height: 100)
                        TextEditor(text: $eventBody)
                            .frame(height: 80)
                            .scrollContentBackground(.hidden)
                            .tint(Color("primary-color"))
                    }
                }.frame(width: SCREEN_WIDTH-25)
                
                
                
                // MARK: - Field picker
                VStack(alignment: .leading){
                    // MARK: - Field picker
                    VStack(alignment: .leading){
                        Text("Club")
                            .font(.title3)
                            .bold()
                        Text("The club affiliated with the event")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Picker(selection: $eventClubId, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                            ForEach(session.myClubs, id: \.id) { club in
                                Text(club.name).tag(club.id)
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
                    
                    Picker(selection: $eventFieldId, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                        ForEach(session.fields, id: \.id) { field in
                            Text(field.name).tag(field.id)
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
                    Picker(selection: $eventLevel, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
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
                    Text("Limit on headcount")
                        .foregroundColor(.gray)
                        .font(.subheadline)

                        HStack {
                            Slider(
                                value: $eventMaxParticipants,
                                in: 0...100,
                                step: 1.0,
                                onEditingChanged: { editing in
                                isEditing = editing
                                }).padding(.leading)
                                .padding(.trailing)
                            Spacer()
                            Text("\(Int(eventMaxParticipants))")
                                .foregroundColor(isEditing ? .red : Color("primary-color"))
                                .padding(.trailing)
                        }.modifier(MenuButton())
                    
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Background Image picker
                VStack(alignment: .leading){
                    HStack {
                        Text("Background Image")
                            .font(.title3)
                        .bold()
                        Spacer()
                    }
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
        }.task {
            eventClubId = session.myClubs[0].id
            eventFieldId = session.fields[0].id
            eventSport = .soccer
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
            .environmentObject(SessionStore())
    }
}
