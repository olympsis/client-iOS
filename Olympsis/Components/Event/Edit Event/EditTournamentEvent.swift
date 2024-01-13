//
//  EditTournamentEvent.swift
//  Olympsis
//
//  Created by Joel on 12/25/23.
//

import SwiftUI

struct EditTournamentEvent: View {
    
    @Binding var event: Event
    
    @State private var isEditing:               Bool = false
    @State private var eventTitle:              String = ""
    @State private var eventBody:               String = ""
    @State private var eventExternalLink:       String = ""
    @State private var eventStartTime:          Date = Date()
    @State private var eventStopTime:           Date = Date().addingTimeInterval(30 * 60)
    @State private var eventImageURL:           String = ""
    @State private var eventSport:              SPORT = .soccer
    @State private var eventLevel:              Int    = 0
    @State private var eventMaxParticipants:    Double = 0
    @State private var eventMinParticipants:    Double = 0

    @State private var hasEndTime: Bool = false
    @State private var showStartTimePicker: Bool = false
    @State private var showStopTimePicker: Bool = false
    
    @State private var eventSkilLevel: EVENT_SKILL_LEVELS = .All
    @State private var eventVisibility: EVENT_VISIBILITY_TYPES = .Public
    
    
    @State private var status: LOADING_STATE = .pending
    @State private var showVisibilityPicker: Bool = false
    @State private var showSkillLevelPicker: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
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
    
    func updateEvent() async {
        var stopTime: Int?
        if hasEndTime {
            stopTime = Int(eventStopTime.timeIntervalSince1970)
        } else {
            stopTime = nil
        }
        
        let dao = EventDao(
            title: eventTitle,
            body: eventBody,
            imageURL: eventImageURL,
            startTime: Int(eventStartTime.timeIntervalSince1970),
            maxParticipants: Int(eventMaxParticipants),
            minParticipants: Int(eventMinParticipants),
            level: eventLevel,
            stopTime: stopTime,
            visibility: eventVisibility.rawValue,
            externalLink: eventExternalLink
        )
        let resp = await session.eventObserver.updateEvent(id: event.id ?? "", dao: dao)
        if resp {
            event.visibility = eventVisibility.rawValue
            event.level = eventSkilLevel.toInt()
            event.title = eventTitle
            event.body = eventBody
            event.externalLink = eventExternalLink
            event.startTime = Int(eventStartTime.timeIntervalSince1970)
            event.stopTime = stopTime
            event.minParticipants = Int(eventMinParticipants)
            event.maxParticipants = Int(eventMaxParticipants)
            event.imageURL = eventImageURL
            event.externalLink = eventExternalLink
            handleSuccess()
        } else {
            handleFailure()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                // MARK: - Top Options
                NewEventTopView(showVisibilityPicker: $showVisibilityPicker, showSkillLevelPicker: $showSkillLevelPicker, eventSkilLevel: $eventSkilLevel, eventVisibility: $eventVisibility)
                
                // MARK: - Title
                VStack(alignment: .leading){
                    Text("Title")
                        .font(.title3)
                        .bold()
                    Text("What to call the event")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $eventTitle)
                        .padding(.leading)
                        .modifier(InputField())
                }.padding(.horizontal)
                
                VStack(alignment: .leading){
                    Text("Description")
                        .font(.title3)
                        .bold()
                    Text("Give details about the event")
                        .foregroundColor(.gray)
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

                // MARK: - External Link
                VStack(alignment: .leading){
                    Text("External Link")
                        .font(.title3)
                        .bold()
                    Text("Link to finish the rsvp process")
                        .font(.subheadline)
                    
                    TextField("", text: $eventExternalLink)
                        .padding(.leading)
                        .modifier(InputField())
                        .contextMenu {
                            Button(action: {
                                if let pasteboardString = UIPasteboard.general.string {
                                    eventExternalLink = pasteboardString
                                }
                            }) {
                                Text("Paste")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                }.padding(.horizontal)
                    .padding(.top)
                
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
                
                Button(action: { Task { await updateEvent() } }) {
                    LoadingButton(text: "Update", status: $status)
                        .padding(.vertical, 59)
                }
            }.navigationTitle("Edit Tournament")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                        }
                    }
                }
                .sheet(isPresented: $showStartTimePicker, content: {
                    EventDatePickerView(eventTime: $eventStartTime)
                        .presentationDetents([.medium])
                })
                .sheet(isPresented: $showStopTimePicker, content: {
                    EventDatePickerView(eventTime: $eventStopTime, startingPoint: eventStartTime.addingTimeInterval(30 * 60))
                        .presentationDetents([.medium])
                })
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
                .onAppear {
                    guard let title = event.title,
                        let body = event.body,
                          let visibility = event.visibility,
                          let level = event.level else {
                        return
                    }
                    eventTitle = title
                    eventBody = body
                    
                    switch visibility {
                    case "public":
                        eventVisibility = .Public
                    case "private":
                        eventVisibility = .Private
                    case "group":
                        eventVisibility = .Group
                    default:
                        eventVisibility = .Public
                    }
                    
                    switch level {
                    case 0:
                        eventSkilLevel = .All
                    case 1:
                        eventSkilLevel = .Beginner
                    case 2:
                        eventSkilLevel = .Amateur
                    case 3:
                        eventSkilLevel = .Expert
                    default:
                        eventSkilLevel = .All
                    }
                    
                    guard let startTime = event.startTime else {
                        return
                    }
                    eventStartTime = Date(timeIntervalSince1970: TimeInterval(startTime))
                    
                    if let stopTime = event.stopTime {
                        eventStopTime = Date(timeIntervalSince1970: TimeInterval(stopTime))
                        hasEndTime = true
                    } else {
                        hasEndTime = false
                    }
                    
                    
                    if let image = event.imageURL {
                        eventImageURL = image
                    }
                    if let minParticipants = event.minParticipants {
                        eventMinParticipants = Double(minParticipants)
                    }
                    if let maxParticipants = event.maxParticipants {
                        eventMaxParticipants = Double(maxParticipants)
                    }
                    if let externalLink = event.externalLink {
                        eventExternalLink = externalLink
                    }
                }
        }
    }
}

#Preview {
    EditTournamentEvent(event: .constant(EVENTS[0]))
}
