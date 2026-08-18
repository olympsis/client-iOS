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

    /// Events/venues control that occupies the navigation bar's principal
    /// (center) slot. `ExplorerPagePicker` is a hand-rolled segmented control
    /// — see its doc comment for why the system `Picker(.segmented)` can't be
    /// sized down without shrinking its labels into illegibility.
    ///
    /// Locked while a fetch is in flight so the user can't flip pages
    /// mid-load (which would show one page's skeletons against the other
    /// page's data). `.disabled` also dims it as a cue.
    @ViewBuilder
    private func pagePicker(selection: Binding<EVENT_EXPLORER_STATE>) -> some View {
        ExplorerPagePicker(selection: selection)
            .disabled(viewModel.state == .loading)
    }

    var body: some View {
        // `@Bindable` re-derives a `Binding` from the environment-injected
        // `@Observable` view model so the toolbar's page picker can write
        // back to `viewModel.page`.
        @Bindable var viewModel = viewModel

        return NavigationStack(path: $router.navPath) {
            EventsExplorer(router: $router, showMenu: $showMenu, showNewEvent: $showNewEvent)
                .environment(session)
                .environment(manager)
                .environment(viewModel)
                .toolbarBackground(.hidden, for: .navigationBar)
                // There's no navigation title here (the picker occupies the
                // principal slot), but SwiftUI still reserves the *large*
                // title area — which made the bar 106pt tall and pushed its
                // touch-absorbing bounds down over the explorer drawer's
                // grabber at the `.large` detent. The bar ate the drag, so
                // the drawer could be pulled up but never back down.
                // Inline mode collapses that dead space and frees the grabber.
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // MARK: - New event (leading)
                    ToolbarItem(placement: .topBarLeading) {
                        if #available(iOS 26.0, *) {
                            Button(action: { showNewEvent.toggle() }) {
                                Image(systemName: "plus")
                            }
                        } else {
                            CircularChip(systemImage: "plus", action: { showNewEvent.toggle() })
                        }
                    }

                    // MARK: - Events / Venues picker (center)
                    //
                    // Takes the place of the old "Olympsis" title.
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .principal) {
                            pagePicker(selection: $viewModel.page)
                        }
                        // Hide the toolbar's own glass capsule — the picker
                        // paints its own track, so the chrome would double up.
                        .sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .principal) {
                            pagePicker(selection: $viewModel.page)
                        }
                    }

                    // MARK: - Search (trailing)
                    ToolbarItem(placement: .topBarTrailing) {
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
