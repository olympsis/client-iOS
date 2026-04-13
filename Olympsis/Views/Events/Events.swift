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
    
    @State private var searchText: String = ""
    
    @State private var showMenu: Bool = false
    @State private var showNewEvent: Bool = false
    
    @State private var manager = SearchManager()
    @State private var viewModel = EventsViewModel()
    @Environment(SessionStore.self) private var session
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                ListView(
                    state: $viewModel.state,
                    searchText: $viewModel.searchText,
                    showNewEvent: $showNewEvent,
                    showMenu: $showMenu,
                    numFiltersActive: viewModel.numFiltersActive
                )
                .environment(session)
                .environment(manager)
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Olympsis")
                            .fixedSize()
                            .italic()
                            .font(.custom("Archivo-Black", size: 30, relativeTo: .largeTitle))
                    }.sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Olympsis")
                            .fixedSize()
                            .italic()
                            .font(.custom("Archivo-Black", size: 30, relativeTo: .largeTitle))
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action:{ router.navigate(to: .new) }){
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }.frame(width: 41)
                }
            }
            .sheet(isPresented: $showMenu, onDismiss: {
                // Detect if filters actually changed so we can force a fresh fetch
                let filtersChanged = manager.selectedTags != viewModel.selectedTags
                    || manager.selectedSports != viewModel.selectedSports
                
                viewModel.selectedTags = manager.selectedTags
                viewModel.selectedSports = manager.selectedSports
                
                Task {
                    await viewModel.fetchEvents(session, force: filtersChanged)
                }
            }, content: {
                FilterView()
                    .environment(session)
                    .environment(manager)
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
                case .event(let event):
                    EventView(event: event)
                        .environment(event)
                        .environment(session)
                case .upNextEvents(let events):
                    UpNextEvents(events: events)
                case .new:
                    NewEvent(manager: NewEventManager())
                case .settings:
                    EventsOptions(availableSports: [], selectedSports: viewModel.sports)
                        .environment(router)
                }
            })
            .task {
                LocationManager.shared.requestLocation()
                
                // Grab sports and tags from session
                manager.tags = session.tags
                manager.sports = session.sports
                viewModel.tags = session.tags
                viewModel.sports = session.sports
                
                // Add user's sports on the filter by default
                if let user = session.user {
                    if let sports = user.sports {
                        manager.selectedSports = sports
                        viewModel.selectedSports = sports
                    }
                }
                
                await viewModel.fetchEvents(session)
            }
        }
    }
}

#Preview {
    Events(router: .constant(EventRouter()))
        .environment(SessionStore())
}
