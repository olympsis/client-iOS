//
//  EventDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import MapKit
import Charts
import SwiftUI
import CoreLocation

struct EventDetailView: View {
    
    @Binding var event:   Event
    @State var club:      Club?
    @State private var showMenu = false
    @State private var showOnboarding = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: SessionStore
    @AppStorage("eventManagementOnboarding") var onboarding:Bool?
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(fieldLocation.coordinates[1]),\(fieldLocation.coordinates[0])")! as URL)
    }
    
    var title: String {
        guard let title = event.title else {
            return "Event"
        }
        return title
    }
    
    var eventBody: String {
        guard let b = event.body else {
            return "Event Body"
        }
        return b
    }
    
    var city: String {
        guard let data = event.data,
              let field = data.field else {
            return "City"
        }
        return field.city
    }
    
    var state: String {
        guard let data = event.data,
              let field = data.field else {
            return "City"
        }
        return field.state
    }
    
    var fieldLocation: GeoJSON {
        guard let data = event.data,
              let field = data.field else {
            return GeoJSON(type: "", coordinates: [0,0])
        }
        return field.location
    }
    
    var fieldName: String {
        guard let data = event.data,
              let field = data.field else {
            return "Field Name"
        }
        return field.name
    }
    
    var eventEnded: Bool {
        return event.status == "ended" ? true : false
    }
    
    var canManipulateEvent: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let status = event.status, // status of event
              let members = club?.members, // members list
              let member = members.first(where: { $0.uuid == uuid }) else { // get members
            return false
        }
        if status == "ended" {
            return false
        }
        if member.role != "member" {
            return true
        }
        if event.poster == uuid {
            return true
        }
        return false
    }
    
    var estimatedTimeToField: Int {
        guard let location = session.locationManager.location else {
            return 10
        }
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let targetLocation = CLLocation(latitude: fieldLocation.coordinates[1], longitude: fieldLocation.coordinates[0])
        let distance = currentLocation.distance(from: targetLocation)
        let speed: CLLocationSpeed = 500 // Assuming a speed of 500 meters/minute
        let timeDifference = distance / speed
        
        if timeDifference < 0 {
            return 1
        }
        
        return Int(timeDifference) // Convert to minutes
    }
    
    var estimatedTimeString: String {
        if estimatedTimeToField == 1 {
            return "1 minute from you"
        } else {
            return "\(estimatedTimeToField) minutes from you"
        }
    }
    
    var yesCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let yesNum = participants.filter { p in
            return p.status == "yes"
        }
        return yesNum.count
    }
    
    var maybeCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let maybeNum = participants.filter { p in
            return p.status == "maybe"
        }
        return maybeNum.count
    }
    
    var noCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let noNum = participants.filter { p in
            return p.status == "no"
        }
        return noNum.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    // MARK: - Event Info
                    VStack(alignment: .leading){
                        Text(title)
                            .foregroundColor(.primary)
                            .bold()
                            .font(.largeTitle)
                        HStack {
                            Text(city)
                                .foregroundColor(.primary)
                                .font(.title)
                            Text(", \(state)")
                                .foregroundColor(.primary)
                                .font(.title)
                        }
                        Text(fieldName)
                            .foregroundColor(.primary)
                            .font(.title3)
                        HStack {
                            Button(action:{ self.leadToMaps() }) {
                                HStack {
                                    Image(systemName: "car")
                                        .foregroundColor(.primary)
                                    .imageScale(.large)
                                    Text(estimatedTimeString)
                                        .foregroundColor(.primary)
                                }
                            }
                        }.padding(.top)
                    }.padding(.top)
                        .padding(.leading)
                        .frame(width: SCREEN_WIDTH, alignment: .leading)
                    
                    // MARK: - Middle View
                    VStack {
                        EventDetailMiddleView(event: $event, showMenu: showMenu)
                    }
                    
                    // MARK: - Event Body
                    VStack(alignment: .leading) {
                        Text(eventBody)
                            .padding(.leading)
                        Text("To learn more about this event, join the hosting club.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }.frame(width: SCREEN_WIDTH, alignment: .leading)
                        .padding(.top)
                        .padding(.bottom)
                    
                    if event.participants != nil {
                        // MARK: - Participants Graph View
                        Chart {
                            BarMark(
                                x: .value("Responses", "yes"),
                                y: .value("Total Count", yesCount)
                            ).foregroundStyle(Color("secondary-color"))
                            BarMark(
                                x: .value("Responses", "Maybe"),
                                y: .value("Total Count", maybeCount)
                            ).foregroundStyle(Color("secondary-color"))
                            BarMark(
                                x: .value("Responses", "No"),
                                y: .value("Total Count", noCount)
                            ).foregroundStyle(Color("secondary-color"))
                        }
                    }
                    
                    // MARK: - Participants View
                    VStack {
                        ScrollView(.horizontal ,showsIndicators: false){
                            HStack {
                                ForEach(event.participants ?? [Participant](), id:\.id) { p in
                                    ParticipantView(participant: p)
                                }
                            } .padding(.leading)
                        }
                    }
                }
            }.sheet(isPresented: $showMenu) {
                EventMenu(event: $event)
                    .presentationDetents([.height(200)])
            }
            .fullScreenCover(isPresented: $showOnboarding, content: {
                RSVP()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ dismiss() }){
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .imageScale(.large)
                    }
                }
                if canManipulateEvent {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EventDetailActionButton(event: $event, showMenu: $showMenu)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.showMenu.toggle()}){
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                    }
                }
            }
            .refreshable {
                guard let id = event.id else {
                    return
                }
                let resp = await session.eventObserver.fetchEvent(id: id)
                if let e = resp {
                    await MainActor.run {
                        self.event = e
                    }
                }
            }.task {
                guard onboarding != nil else {
                    showOnboarding = true
                    onboarding = true
                    return
                }
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: .constant(EVENTS[0]))
            .environmentObject(SessionStore())
    }
}
