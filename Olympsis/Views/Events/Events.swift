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
                    Button(action:{ self.showNewEvent = true }){
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }.frame(width: 41)
                }
            }
            .fullScreenCover(isPresented: $showNewEvent, onDismiss: {
                Task {
                    await viewModel.fetchEvents(session, force: true)
                }
            }) {
                NewEvent(manager: NewEventManager())
            }
            .sheet(isPresented: $showMenu, onDismiss: {
                viewModel.selectedTags = manager.selectedTags
                viewModel.selectedSports = manager.selectedSports
                
                Task {
                    await viewModel.fetchEvents(session)
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
                case .settings:
                    EventsOptions(availableSports: [], selectedSports: viewModel.sports)
                        .environment(router)
                }
            })
            .task {
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
