//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import SwiftUI
import AlertToast

struct NewEventView: View {
    
    enum Sports: String, CaseIterable {
        case soccer     = "⚽️ Soccer"
        case basketball = "🏀 Basketball"
        case cricket    = "🏏 Cricket"
        case volleyball = "🏐 Volleyball"
        case tennis     = "🎾 Tennis"
        case pickleball = "pickleball"
    }
    
    func getSportRawText(for sport: Sports) -> String {
        switch sport {
        case .soccer:
            return "soccer"
        case .basketball:
            return "basketball"
        case .cricket:
            return "cricket"
        case .volleyball:
            return "volleyball"
        case .tennis:
            return "tennis"
        case .pickleball:
            return "pickleball"
        }
    }
    
    func getSportImages(for sport: Sports) -> [String] {
        switch sport {
        case .soccer:
            return ["soccer-0","soccer-1"]
        case .basketball:
            return ["basketball-0", "basketball-1", "basketball-2","basketball-4", "basketball-5"]
        case .cricket:
            return [""]
        case .volleyball:
            return [""]
        case .tennis:
            return ["tennis-0", "tennis-1", "tennis-2", "tennis-3"]
        case .pickleball:
            return [""]
        }
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
    
    @State private var isEditing:               Bool = false
    @State private var showCompletedToast:      Bool = false
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var eventFieldId:            String = ""
    @State private var eventClubId:             String = ""
    @State private var eventStartTime:          Date = Date()
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              Sports = .soccer
    @State private var eventLevel:              Int    = 1
    @State private var eventMaxParticipants:    Double = 0
    
    @State private var showSuccess  = false
    @State private var showFaillure = false
    
    @StateObject private var eventObserver =  EventObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func CreateEvent() async {
        let status = "pending"
        let now = Int(eventStartTime.timeIntervalSince1970)
        print(eventClubId)
        let dao = EventDao(_title: eventTitle, _body: eventBody, _clubId: eventClubId, _fieldId: eventFieldId, _imageURL: eventImageURL, _sport: getSportRawText(for: eventSport), _startTime: now, _maxParticipants: Int(eventMaxParticipants), _level: eventLevel, _status: status)
        let res = await eventObserver.createEvent(dao: dao)
        if res {
            self.showCompletedToast.toggle()
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
                        
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .frame(height: 40)
                        TextField("title", text: $eventTitle)
                            .padding(.leading)
                            .tint(Color("primary-color"))
                            
                    }.frame(width: SCREEN_WIDTH-50)
                }
                
                // MARK: - Sports picker
                VStack(alignment: .leading){
                    Text("Sport")
                        .font(.title3)
                        .bold()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .frame(height: 40)
                        Picker(selection: $eventSport, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                            ForEach(Sports.allCases, id: \.rawValue) { sport in
                                Text(sport.rawValue).tag(sport)
                            }
                        }.frame(width: SCREEN_WIDTH/2)
                            .tint(Color("primary-color"))
                    }
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Description
                VStack(alignment: .leading){
                    Text("Description")
                        .font(.title3)
                        .bold()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .frame(height: 100)
                        TextEditor(text: $eventBody)
                            .padding(.leading)
                            .frame(height: 80)
                            .scrollContentBackground(.hidden)
                            .tint(Color("primary-color"))
                    }
                }.frame(width: SCREEN_WIDTH-50)
                
                
                
                // MARK: - Field picker
                VStack(alignment: .leading){
                    // MARK: - Field picker
                    VStack(alignment: .leading){
                        Text("Club")
                            .font(.title3)
                            .bold()

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("secondary-color"))
                                .opacity(0.3)
                                .frame(height: 40)
                            Picker(selection: $eventClubId, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                                ForEach(session.myClubs, id: \.id) { club in
                                    Text(club.name).tag(club.id)
                                }
                            }.frame(width: SCREEN_WIDTH/2)
                                .tint(Color("primary-color"))
                        }
                    }.padding(.top)
                        .frame(width: SCREEN_WIDTH-50)
                        .padding(.bottom)
                    Text("Field")
                        .font(.title3)
                        .bold()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .frame(height: 40)
                        Picker(selection: $eventFieldId, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                            ForEach(session.fields, id: \.id) { field in
                                Text(field.name).tag(field.id)
                            }
                        }.frame(width: SCREEN_WIDTH/2)
                            .tint(Color("primary-color"))
                    }
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Date/Time picker
                VStack(alignment: .leading){
                    Text("Start Date/Time")
                        .font(.title3)
                        .bold()
                    DatePicker(selection: $eventStartTime, label: { Text("") })
                        .datePickerStyle(.graphical)
                        .tint(Color("primary-color"))

                }.padding(.top, 30)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Skill Level picker
                VStack(alignment: .leading){
                    Text("Skill Level")
                        .font(.title3)
                        .bold()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .frame(height: 40)
                        Picker(selection: $eventLevel, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                            ForEach(SkillLevel.allCases, id: \.rawValue) { skill in
                                Text(skill.rawValue).tag(getSkillRaw(for: skill))
                            }
                        }.frame(width: SCREEN_WIDTH/2)
                            .tint(Color("primary-color"))
                    }
                }.padding(.top)
                    .frame(width: SCREEN_WIDTH-50)
                
                // MARK: - Max Participants slider
                VStack(alignment: .leading){
                    Text("Max Participants")
                        .font(.title3)
                        .bold()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .frame(height: 40)
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
                        }
                    }
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
                            ForEach(getSportImages(for: eventSport), id: \.self) { image in
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
                    Button(action: {
                        Task {
                            await CreateEvent()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 35)
                                .foregroundColor(Color("primary-color"))
                            Text("Create")
                                .foregroundColor(.white)
                        }
                    }
                }.padding(.top, 50)
                    
            }.frame(width: SCREEN_WIDTH)
                .toast(isPresenting: $showCompletedToast,duration: 1, alert: {
                    AlertToast(displayMode: .banner(.pop), type: .regular, title: "Event Created!", style: .style(titleColor: .white, titleFont: .callout))
                })
                .task {
                    if !session.fields.isEmpty {
                        eventFieldId = session.fields[0].id
                    }
                    
                    if !session.myClubs.isEmpty {
                        eventClubId = session.myClubs[0].id
                    }
                    
                }
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView().environmentObject(SessionStore())
    }
}
