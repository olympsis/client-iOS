//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

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
    
    @State var clubs: [Club]
    @State var fields: [Field]
    @State var sports: [String]
    
    @State private var isEditing:               Bool = false
    @State private var showCompletedToast:      Bool = false
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var eventFieldId:            String = ""
    @State private var eventClubId:             String = ""
    @State private var eventStartTime:          Date = Date()
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              SPORT = .soccer
    @State private var eventLevel:              Int    = 1
    @State private var eventMaxParticipants:    Double = 1
    @State private var status:                  LOADING_STATE = .pending
    @State private var validationStatus:        NEW_EVENT_ERROR = .unexpected
    
    @StateObject private var eventObserver =  EventObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var convertedSports: [SPORT] {
        var res = [SPORT]()
        for sport in sports {
            res.append(SportFromString(s: sport))
        }
        return res
    }
    
    var associatedClubs: [Club] {
        return clubs.filter({$0.sport == eventSport.rawValue})
    }
    
    var associatedFields: [Field] {
        return fields.filter({$0.sports.contains(where: {$0 == eventSport.rawValue})})
    }
    
    var selectedClub: String {
        if eventClubId != "" {
            return eventClubId
        } else {
            return associatedClubs[0].id
        }
    }
    
    var selectedField: String {
        if eventFieldId != "" {
            return eventFieldId
        } else {
            return associatedFields[0].id
        }
    }
    
    var selectedImage: String {
        if eventImageURL != "" {
            return eventImageURL
        } else {
            return eventSport.Images()[Int.random(in: 0...eventSport.Images().count)]
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
            return
        }
        status = .loading
        let dao = EventDao(title: eventTitle, body: eventBody, clubId: selectedClub, fieldId: selectedField, imageURL: eventImageURL, sport: eventSport.rawValue, startTime: Int(eventStartTime.timeIntervalSince1970), maxParticipants: Int(eventMaxParticipants), level: eventLevel, status: "pending")
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
                    
                    Picker(selection: $eventSport, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                        ForEach(convertedSports, id: \.rawValue) { sport in
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
                        
                        Picker(selection: $eventClubId, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                            ForEach(associatedClubs, id: \.id) { club in
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
                        ForEach(associatedFields, id: \.id) { field in
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
        }.task {
            eventClubId = clubs[0].id
            //eventFieldId = session.fields[0].id
            eventSport = SportFromString(s: sports[0])
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        let clubs = [
            Club(id: "0", name: "Provo Soccer", description: "Come play soccer with us.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "clubs/36B2B94A-8152-4CE5-AC9B-94455DBE9643", isPrivate: false, members: [Member](), rules: ["Don't steal", "No Fighting"], createdAt: 0),
            Club(id: "1", name: "Provo Golf", description: "Come play golf with us.", sport: "golf", city: "Provo", state: "Utah", country: "United States of America", imageURL: "clubs/36B2B94A-8152-4CE5-AC9B-94455DBE9643", isPrivate: false, members: [Member](), rules: ["Don't steal", "No Fighting"], createdAt: 0)
            ]
        let fields = [
            Field(id: "0", owner: "", name: "Lionne Park", notes: "Grass Field", sports: ["soccer"], images: ["fields/78c7efcd-6ec3-4324-a468-ad0ea1e0c177.jpg"], location: GeoJSON(type: "", coordinates: [0.0]), city: "Stamford", state: "Connecticut", country: "United States", isPublic: false),
            Field(id: "1", owner: "", name: "Country Club Park", notes: "Grass Field", sports: ["golf"], images: ["fields/78c7efcd-6ec3-4324-a468-ad0ea1e0c177.jpg"], location: GeoJSON(type: "", coordinates: [0.0]), city: "Stamford", state: "Connecticut", country: "United States", isPublic: false),
            Field(id: "2", owner: "", name: "Other Club Park", notes: "Grass Field", sports: ["golf", "soccer"], images: ["fields/78c7efcd-6ec3-4324-a468-ad0ea1e0c177.jpg"], location: GeoJSON(type: "", coordinates: [0.0]), city: "Stamford", state: "Connecticut", country: "United States", isPublic: false)
        ]
        NewEventView(clubs: clubs, fields: fields, sports: ["soccer", "golf"])
            .environmentObject(SessionStore())
    }
}
