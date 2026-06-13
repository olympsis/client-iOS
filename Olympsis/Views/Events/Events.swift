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
    
    // `SearchManager` hydrates `selectedTags` / `selectedSports` from
    // UserDefaults in its init, so the user's filter choices survive
    // across app launches without any work here.
    @State private var manager = SearchManager()
    @State private var viewModel = EventsViewModel()
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
                        if #available(iOS 26.0, *) {
                            Button(action: { router.navigate(to: .new) }) {
                                Image(systemName: "plus")
                            }
                        } else {
                            CircularChip(systemImage: "plus", action: { router.navigate(to: .new) })
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
                    // Decide whether the dismiss should trigger a network
                    // fetch or just a local re-filter.
                    let oldTags = Set(viewModel.selectedTags)
                    let oldSports = Set(viewModel.selectedSports)
                    let newTags = Set(manager.selectedTags)
                    let newSports = Set(manager.selectedSports)

                    let hasAdditions = !newTags.isSubset(of: oldTags)
                        || !newSports.isSubset(of: oldSports)
                    let clearedAllFilters = newTags.isEmpty && newSports.isEmpty
                        && (!oldTags.isEmpty || !oldSports.isEmpty)
                    let needsFetch = hasAdditions || clearedAllFilters

                    viewModel.selectedTags = manager.selectedTags
                    viewModel.selectedSports = manager.selectedSports

                    if needsFetch {
                        Task {
                            await viewModel.fetchEvents(session, force: true)
                        }
                    }
                }, content: {
                    FilterView(showTags: viewModel.page == .events)
                        .environment(session)
                        .environment(manager)
                        .presentationDragIndicator(.visible)
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
                    case .new:
                        NewEvent(manager: NewEventManager())
                    case .venue(let venue):
                        VenueView(venue: venue, isFullScreen: true)
                            .environment(session)
                    }
                })
                .task {
                    LocationManager.shared.requestLocation()

                    // Grab sports and tags from session
                    manager.tags = session.tags
                    manager.sports = session.sports
                    viewModel.tags = session.tags
                    viewModel.sports = session.sports

                    // First-launch seed: only apply the user's preferred
                    // sports when nothing has ever been persisted. If the
                    // user has touched the filter sheet before — even to
                    // clear it — we respect that and skip the seed.
                    // `manager` already hydrated `selectedSports` /
                    // `selectedTags` from `UserDefaults` in its init, so
                    // this branch is the only place defaults are applied.
                    if !manager.hasPersistedSelections,
                       let sports = session.user?.sports {
                        manager.selectedSports = sports
                        manager.persistSelections()
                    }

                    // Mirror the (persisted or seeded) selection onto the
                    // viewModel so the very first fetch uses it and the
                    // dismiss-diff in the filter sheet has the right
                    // "previous" baseline.
                    viewModel.selectedSports = manager.selectedSports
                    viewModel.selectedTags = manager.selectedTags

                    // Give Core Location up to 1 s to deliver a fresh fix
                    // before we kick off the network call. If nothing comes
                    // through in time, `viewModel.currentLocation` falls back
                    // to its built-in default — same query, just with the
                    // fallback coords.
                    _ = await LocationManager.shared.waitForLocation(timeout: 1.0)

                    await viewModel.fetchData(session)
                }
        }
    }
}

#Preview {
    Events(router: .constant(EventRouter()))
        .environment(SessionStore())
}
