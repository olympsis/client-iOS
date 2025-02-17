//
//  Events.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import SwiftUI

struct Events: View {
    
    @StateObject var router: EventRouter = EventRouter()
    
    @State private var state: EVENTS_PAGE_STATE = .list
    
    @State private var showError: Bool = false
    @State private var showBottomSheet: Bool = false
    @State private var showFieldDetail: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showOptions: Bool = false
    @State private var selectedVenue: Venue?
    @State private var selectedEvent: Event?
    
    @State private var todayDate = Date()
    @State private var selectedDate = Date()
    
    @State private var searchText = ""
    
    @Environment(SessionStore.self) private var session
    
    private var sports: [SPORTS] {
        guard let user = session.user,
              let sports = user.sports else {
            return [SPORTS]()
        }
        var arr = [SPORTS]()
        sports.forEach {
            if let s = SPORTS(rawValue: $0) {
                arr.append(s)
            }
        }
        return arr
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                switch state {
                case .list:
                    ListView(showNewEvent: $showNewEvent)
                        .environment(session)
                case .map:
                    MapView(showNewEvent: $showNewEvent, selectedVenue: $selectedVenue)
                        .environment(session)
                }
            }
            .overlay(alignment: .topTrailing) {
                HStack {
                    Text("Events")
                        .font(.title)
                        .bold()
                    
                    Spacer()

                    HStack {
                        Button(action:{ self.showNewEvent = true }){
                            switch state {
                            case .list:
                                Image(systemName: "plus")
                                    .imageScale(.large)
                            case .map:
                                ZStack {
                                    Circle()
                                        .tint(Color.colorPrime)
                                    Image(systemName: "plus")
                                        .imageScale(.large)
                                        .symbolRenderingMode(.palette)
                                        .foregroundColor(.white)
                                }
                            }
                        }.frame(width: 41)
                        
                        Button(action:{
                            withAnimation(.easeInOut) {
                                switch state {
                                case .list:
                                    state = .map
                                case .map:
                                    state = .list
                                }
                            }
                        }){
                            Group {
                                switch state {
                                case .list:
                                    Image(systemName: "map")
                                        .imageScale(.large)
                                case .map:
                                    Circle()
                                        .tint(Color.colorPrime)
                                        .overlay {
                                            Image(systemName: "line.3.horizontal.decrease")
                                                .imageScale(.large)
                                                .symbolRenderingMode(.palette)
                                                .foregroundColor(.white)
                                            
                                        }
                                }
                            }
                            .frame(width: 41)
                            .overlay(alignment: .topTrailing) {
                                if session.events.count > 0 {
                                    Circle()
                                        .foregroundStyle(.red)
                                        .frame(width: 15, height: 15)
                                }
                            }
                        }
                        .frame(width: 41)
                        .padding(.top, 2)
                        
                        Button(action:{ self.router.navigate(to: .settings) }){
                            switch state {
                            case .list:
                                Image(systemName: "slider.horizontal.3")
                                    .imageScale(.large)
                            case .map:
                                ZStack {
                                    Circle()
                                        .tint(Color.colorPrime)
                                        .frame(width: 41, height: 41)
                                    Image(systemName: "slider.vertical.3")
                                        .imageScale(.large)
                                        .symbolRenderingMode(.palette)
                                        .foregroundColor(.white)
                                }
                            }
                        }.frame(width: 41)
                    }.frame(height: 41)
                }
                .frame(height: 35)
                .padding(.leading)
                .padding(.trailing, 5)
            }
            .background {
                Color.Background.primary
                    .edgesIgnoringSafeArea(.all)
            }
            .sheet(item: $selectedVenue) { field in
                VenueView(venue: field)
                    .presentationDetents([.height(250), .large])
            }
            .fullScreenCover(isPresented: $showNewEvent, onDismiss: {
                Task {
                    await session.getNearbyData(location: session.currentLocation.center)
                }
            }) {
                NewEvent(manager: NewEventManager())
            }
            .navigationDestination(for: EVENT_ROUTES.self, destination: { route in
                switch route {
                case .events(let eventId, let openEvents):
                    if let eventId {
                        AsyncEventView(eventId: eventId)
                            .toolbar(.hidden, for: .navigationBar)
                    } else if openEvents != nil && openEvents == true {
                        EventsList(events: session.events)
                    }
                case .settings:
                    EventsOptions(availableSports: SPORTS.allCases, selectedSports: sports)
                        .environmentObject(router)
                }
            })
        }
    }
}

#Preview {
    Events()
        .environment(SessionStore())
}
