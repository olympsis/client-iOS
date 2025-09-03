//
//  Events.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import MapKit
import SwiftUI

struct Events: View {
    
    @Binding var router: EventRouter
    
    @State private var isLoaded: Bool = false
    @State private var searchText: String = ""
    
    @State private var state: VIEW_STATE = .pending
    @State private var page: EVENTS_PAGE_STATE = .list
    
    @State private var numFiltersActive = 0
    @State private var showMenu: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var selectedVenue: Venue?
    
    @State private var manager = SearchManager()
    @Environment(SessionStore.self) private var session
    
    private var fallbackLocation: CLLocation {
        guard let user = session.user, let hometown = user.hometown else {
            return CLLocation(latitude: 37.334886, longitude: -122.008988)
        }
        return CLLocation(latitude: hometown[0], longitude: hometown[1])
    }
    
    private var currentLocation: CLLocation {
        guard LocationManager.shared.isLocationAuthorized,
            let location = LocationManager.shared.location else {
            return fallbackLocation
        }
        
        return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    private var sports: [Sport] {
        return session.sports
    }
    
    private func fetchEvents() async {
        state = .loading
        
        var tags: String? = nil
        var sports: String? = nil
        
        if (!manager.tags.isEmpty) {
            tags = manager.getTagsString()
        }
        
        if (!manager.sports.isEmpty) {
            sports = manager.getSportsString()
        }
        
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: currentLocation.coordinate.longitude,
            latitude: currentLocation.coordinate.latitude,
            radius: manager.radius,
            tags: tags,
            sports: sports) else {
            state = .failure
            return
        }
        
        resp.forEach { session.events.insert($0) }
        
        state = .success
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                switch page {
                case .list:
                    ListView(
                        state: $state,
                        searchText: $searchText,
                        showNewEvent: $showNewEvent,
                        showMenu: $showMenu,
                        numFiltersActive: $numFiltersActive
                    )
                        .environment(session)
                        .environment(manager)
                case .map:
                    MapView(showNewEvent: $showNewEvent, selectedVenue: $selectedVenue)
                        .environment(session)
                        .environment(manager)
                }
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Events")
                            .fixedSize()
                            .fontWeight(.bold)
                            .font(.custom("Archivo-Black", size: 30, relativeTo: .title))
                    }.sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Events")
                            .fixedSize()
                            .fontWeight(.bold)
                            .font(.custom("Archivo-Black", size: 30, relativeTo: .title))
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action:{ self.showNewEvent = true }){
                        switch page {
                        case .list:
                            Image(systemName: "plus")
                                .imageScale(.large)
                        case .map:
                            if #available(iOS 26.0, *) {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .foregroundColor(.primary)
                                    .symbolRenderingMode(.palette)
                            } else {
                                Circle()
                                    .tint(Color.colorPrime)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Image(systemName: "plus")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                            .symbolRenderingMode(.palette)
                                    }
                            }
                        }
                    }.frame(width: 41)
                    
                    Button(action:{
                        withAnimation(.easeInOut) {
                            switch page {
                            case .list:
                                page = .map
                            case .map:
                                page = .list
                            }
                        }
                    }){
                        Group {
                            switch page {
                            case .list:
                                Image(systemName: "map")
                                    .imageScale(.large)
                            case .map:
                                if #available(iOS 26.0, *) {
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .imageScale(.large)
                                        .foregroundColor(.primary)
                                        .symbolRenderingMode(.palette)
                                } else {
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
            .toolbarBackground(page == .list ? .automatic : .hidden, for: .navigationBar)
            .sheet(item: $selectedVenue) { field in
                VenueView(venue: field)
                    .presentationDetents([.height(250), .large])
            }
            .fullScreenCover(isPresented: $showNewEvent, onDismiss: {
                Task {
                    await fetchEvents()
                }
            }) {
                NewEvent(manager: NewEventManager())
            }
            .sheet(isPresented: $showMenu, onDismiss: {
                withAnimation(.easeInOut) {
                    numFiltersActive = manager.selectedSports.count + manager.selectedTags.count
                    
                    Task {
                        await fetchEvents()
                    }
                }
            }, content: {
                FilterView(manager: manager)
                    .environment(session)
                    .presentationDragIndicator(.visible)
            })
            .navigationDestination(for: EVENT_ROUTES.self, destination: { route in
                switch route {
                case .events(let id, _):
                    if let id {
                        AsyncEventView(eventId: id)
                    } else {
                        EventsList(events: Array(session.events))
                    }
                case .settings:
                    EventsOptions(availableSports: [], selectedSports: sports)
                        .environment(router)
                }
            })
            .task {
                // Grab sports and tags from session
                manager.tags = session.tags
                manager.sports = session.sports
                
                // Add user's sports on the filter by default
                if let user = session.user {
                    if let sports = user.sports {
                        manager.selectedSports = sports
                        
                        withAnimation(.easeInOut) {
                            numFiltersActive = manager.selectedSports.count + manager.selectedTags.count
                        }
                    }
                }
                
                if !isLoaded {
                    await fetchEvents()
                }
            }
        }
    }
}

#Preview {
    Events(router: .constant(EventRouter()))
        .environment(SessionStore())
}
