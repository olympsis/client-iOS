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
    
    @State private var locationManager = LocationManager.shared
    @Environment(SearchManager.self) private var manager
    @Environment(EventsViewModel.self) private var viewModel
    @Environment(SessionStore.self) private var session
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            EventsExplorer(router: $router, showMenu: $showMenu, showNewEvent: $showNewEvent)
                .environment(session)
                .environment(manager)
                .environment(viewModel)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Olympsis")
                                .fixedSize()
                                .italic()
                                .font(.custom("Archivo-Black", size: 25, relativeTo: .largeTitle))
                        }.sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Olympsis")
                                .fixedSize()
                                .italic()
                                .font(.custom("Archivo-Black", size: 25, relativeTo: .largeTitle))
                        }
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if #available(iOS 26.0, *) {
                            Button(action: { showNewEvent.toggle() }) {
                                Image(systemName: "plus")
                            }
                        } else {
                            CircularChip(systemImage: "plus", action: { showNewEvent.toggle() })
                        }
                        if #available(iOS 26.0, *) {
                            Button(action: { viewModel.isSearchActive.toggle() }) {
                                Image(systemName: "magnifyingglass")
                            }
                        } else {
                            CircularChip(systemImage: "magnifyingglass", action: { viewModel.isSearchActive.toggle() })
                        }
                    }
                }
                .sheet(isPresented: $showMenu, onDismiss: {
                    Task {
                        await viewModel.applyFilterChanges(from: manager, in: session)
                    }
                }, content: {
                    FilterView(showTags: viewModel.page == .events)
                        .environment(session)
                        .environment(manager)
                        .presentationDragIndicator(.visible)
                })
                .sheet(isPresented: $showNewEvent, content: {
                    NewEvent(manager: NewEventManager())
                })
                .navigationDestination(for: EVENT_ROUTES.self, destination: { route in
                    switch route {
                    case .events(let id, _, let focus):
                        if let id {
                            AsyncEventView(eventId: id, focus: focus)
                        } else {
                            EventsList(events: Array(session.events))
                        }
                    case .event(let event):
                        EventView(event: event)
                            .environment(event)
                            .environment(session)
                    case .upNextEvents(let events):
                        UpNextEvents(events: events)
                            .environment(session)
                    case .venue(let venue):
                        VenueView(venue: venue, isFullScreen: true)
                            .environment(session)
                    }
                })
                .task {
                    // Permission is intentionally requested only after the
                    // person visits Events, not while ViewContainer launches.
                    locationManager.requestLocation()
                }
                .onChange(of: locationManager.isLocationAuthorized) { wasAuthorized, isAuthorized in
                    guard !wasAuthorized, isAuthorized else { return }

                    Task {
                        // Give the newly-authorized location manager a moment
                        // to deliver a fix before replacing the fallback data.
                        _ = await locationManager.waitForLocation(timeout: 1.0)
                        await viewModel.fetchData(session, force: true)
                    }
                }
        }
    }
}

#Preview {
    Events(router: .constant(EventRouter()))
        .environment(SessionStore())
        .environment(SearchManager())
        .environment(EventsViewModel())
}
