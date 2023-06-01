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
                    let resp = await clubObserver.getClub(id: event.clubID)
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
                    EventDetailActions(event: $event, showMenu: $showMenu, user: USERS_DATA[0], eventObserver: eventObserver)
                        .opacity(event.status == "ended" ? 0 : 1)
                }
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: .constant(EVENTS[0]), field: FIELDS[0], events: .constant(EVENTS), club: CLUBS[0])
            .environmentObject(SessionStore())
    }
}
