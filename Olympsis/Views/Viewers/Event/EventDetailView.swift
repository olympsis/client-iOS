//
//  EventDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import MapKit
import SwiftUI

struct EventDetailView: View {
    
    @Binding var event:             Event
    @State var field:               Field
    @Binding var events:            [Event]
    @State var club:                Club?
    
    @State private var showMenu = false
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var eventObserver = EventObserver()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: SessionStore
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[1]),\(field.location.coordinates[0])")! as URL)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing){
                ScrollView(showsIndicators: false) {
                    // MARK: - Event Info
                    VStack(alignment: .leading){
                        Text(event.title)
                            .foregroundColor(.primary)
                            .bold()
                            .font(.largeTitle)
                        HStack {
                            Text(field.city)
                                .foregroundColor(.primary)
                                .font(.title)
                            Text(", \(field.state)")
                                .foregroundColor(.primary)
                                .font(.title)
                        }
                        Text(field.name)
                            .foregroundColor(.primary)
                            .font(.title3)
                        HStack {
                            Button(action:{ self.leadToMaps() }) {
                                Image(systemName: "location")
                                    .foregroundColor(.primary)
                                    .imageScale(.large)
                            }
                            Text("Directions")
                                .foregroundColor(.primary)
                        }.padding(.top)
                    }.padding(.top)
                        .padding(.leading)
                        .frame(width: SCREEN_WIDTH, alignment: .leading)
                    
                    // MARK: - Middle View
                    EventDetailMiddleView(event: $event)
                    
                    // MARK: - Event Body
                    VStack(alignment: .leading) {
                        Text(event.body)
                        Text("To learn more about this event, join the hosting club.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }.frame(width: SCREEN_WIDTH, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                        .padding(.bottom)
                    
                    EventParticipantsView(event: $event)
                    
                    EventDetailFieldView(field: field)
                        .padding(.top)
                    
                    if let c = club {
                        EventDetailHostClubView(club: c)
                            .padding(.top, 20)
                    }
                }.task {
                    let resp = await clubObserver.getClub(id: event.clubId)
                    if let c = resp {
                        await MainActor.run {
                            self.club = c
                        }
                    }
                }
                .sheet(isPresented: $showMenu) {
                    EventMenu(event: event, events: $events)
                        .presentationDetents([.height(200)])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{ dismiss() }){
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                                .imageScale(.large)
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
                    let resp = await eventObserver.fetchEvent(id: event.id)
                    if let e = resp {
                        await MainActor.run {
                            event = e
                        }
                    }
                }
                if let usr = session.user {
                    EventDetailActions(event: $event, showMenu: $showMenu, user: usr, eventObserver: eventObserver)
                        .opacity(event.status == "ended" ? 0 : 1)
                } else {
                    EventDetailActions(event: $event, showMenu: $showMenu, user: UserStore(firstName: "", lastName: "", email: "", uuid: "", username: "", visibility: "private"), eventObserver: eventObserver)
                        .opacity(event.status == "ended" ? 0 : 1)
                }
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let participant = Participant(id: "0", uuid: "", status: "going", data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "", bio: "", sports: [""]), createdAt: 0)
        let participant2 = Participant(id: "1", uuid: "", status: "going", data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "profile-images/62D674D2-59D2-4095-952B-4CE6F55F681F", bio: "", sports: [""]), createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "pending", startTime: 0, maxParticipants: 0, participants: [participant2,participant])
        let field = Field(id: "", owner: "", name: "Richard Building Fields", notes: "Private field owned by BYU. Turf field with medium sized goals.", sports: [""], images: [""], location: GeoJSON(type: "", coordinates: [-111.656757, 40.247278]), city: "Provo", state: "Utah", country: "United States of America", ownership: "private")
        let club = Club(id: "", name: "Provo Soccer", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "clubs/36B2B94A-8152-4CE5-AC9B-94455DBE9643", isPrivate: false, members: [Member(id: "0", uuid: "00", role: "admin", data: nil, joinedAt: 0), Member(id: "1", uuid: "000", role: "admin", data: nil, joinedAt: 0)], rules: ["No fighting"], createdAt: 0)
        EventDetailView(event: .constant(event), field: field, events: .constant([Event]()), club: club)
            .environmentObject(SessionStore())
    }
}
