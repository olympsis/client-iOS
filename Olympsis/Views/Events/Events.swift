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
    
    @State private var numFiltersActive = 0
    @State private var showMenu: Bool = false
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
    
    @State private var manager = SearchManager()
    @Environment(SessionStore.self) private var session
    
    private var sports: [Sport] {
        return session.sports
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                switch state {
                case .list:
                    ListView(showNewEvent: $showNewEvent, showMenu: $showMenu, numFiltersActive: $numFiltersActive)
                        .environment(session)
                case .map:
                    MapView(showNewEvent: $showNewEvent, selectedVenue: $selectedVenue)
                        .environment(session)
                }
            }

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Events")
                        .font(.title)
                        .bold()
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action:{ self.showNewEvent = true }){
                        switch state {
                        case .list:
                            Image(systemName: "plus")
                                .imageScale(.large)
                        case .map:
                            ZStack {
                                Circle()
                                    .tint(Color.colorPrime)
                                    .frame(width: 40, height: 40)
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
                                    .frame(width: 40, height: 40)
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
                    .padding(.trailing)
                }
            }
            .toolbarBackground(state == .list ? .visible : .hidden, for: .navigationBar)
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
            .sheet(isPresented: $showMenu, onDismiss: {
                withAnimation(.easeInOut) {
                    numFiltersActive = manager.selectedSports.count + manager.selectedTags.count
                }
            }, content: {
                FilterView(manager: manager)
                    .environment(session)
            })
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
                    EventsOptions(availableSports: [], selectedSports: sports)
                        .environmentObject(router)
                }
            })
            .task {
                manager.tags = session.tags
                manager.sports = session.sports
            }
        }
    }
}

#Preview {
    Events()
        .environment(SessionStore())
}
