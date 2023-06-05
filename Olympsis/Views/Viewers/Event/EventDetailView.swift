//
//  EventDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import MapKit
import SwiftUI

struct EventDetailView: View {
    
    @Binding var event:   Event
    @Binding var events:  [Event]
    @State var club:      Club?
    @State private var showMenu = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: SessionStore
    
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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing){
                ScrollView(showsIndicators: false) {
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
                        Text(eventBody)
                        Text("To learn more about this event, join the hosting club.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }.frame(width: SCREEN_WIDTH, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                        .padding(.bottom)
                    
                    EventParticipantsView(event: $event)
                    
                    if let field = event.data?.field {
                        EventDetailFieldView(field: field)
                            .padding(.top)
                    }
                    
                    if let club = event.data?.club {
                        EventDetailHostClubView(club: club)
                            .padding(.top, 20)
                    }
                }.sheet(isPresented: $showMenu) {
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
                    guard let id = event.id else {
                        return
                    }
                    let resp = await session.eventObserver.fetchEvent(id: id)
                    if let e = resp {
                        await MainActor.run {
                            event = e
                        }
                    }
                }
                EventDetailActions(event: $event, showMenu: $showMenu)
                    .opacity(event.status == "ended" ? 0 : 1)
                    .disabled(eventEnded)
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: .constant(EVENTS[0]), events: .constant(EVENTS))
            .environmentObject(SessionStore())
    }
}
