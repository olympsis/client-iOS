//
//  EventsViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/25/26.
//

import MapKit
import SwiftUI
import Foundation
import CoreLocation

@MainActor
@Observable
class EventsViewModel {
    
    var searchText = ""
    /// Drives the floating search bar at the bottom of `EventsExplorer`.
    /// Toggled by the magnifying-glass button in the `Events` toolbar so
    /// the bar slides up over the keyboard on demand instead of living
    /// inside the drawer.
    var isSearchActive: Bool = false
    var events = [Event]()
    
    var radius: Double = 10
    
    var tags: [Tag] = []
    var sports: [Sport] = []
    var selectedTags: [String] = []
    var selectedSports: [String] = []
    
    var mapRegion: MKCoordinateRegion?
    
    var numFiltersActive: Int {
        selectedTags.count + selectedSports.count
    }
    
    // Per-resource load states. Tracking events and venues independently
    // lets the explorer show one page's data while the other is still
    // loading or has failed — and lets `retry` re-fetch only what failed.
    var eventsState: VIEW_STATE = .loading
    var venuesState: VIEW_STATE = .loading

    /// Aggregate state for callers that don't care which resource is which
    /// (e.g. disabling the page picker while anything is in flight). Loading
    /// wins over failure wins over pending wins over success.
    var state: VIEW_STATE {
        if eventsState == .loading || venuesState == .loading { return .loading }
        if eventsState == .failure || venuesState == .failure { return .failure }
        if eventsState == .pending || venuesState == .pending { return .pending }
        return .success
    }

    var page: EVENT_EXPLORER_STATE = .events
    
    private var lastUpdate: Date?
    private var lastVenuesUpdate: Date?
    
    @ObservationIgnored
    @AppStorage("searchRadius") private var searchRadius: Double? // search radius for fields/events in meters
    
    var currentLocation: CLLocation {
        guard LocationManager.shared.isLocationAuthorized,
              let location = LocationManager.shared.location else {
            return CLLocation(latitude: 37.334886, longitude: -122.008988)
        }

        return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }

    /// Center used for explorer queries. Prefers the live device location;
    /// when that's unavailable it falls back to the user's saved hometown —
    /// the same source `FilterView` uses for its map center — so the radius
    /// circle on the filter map and the `/v1/venues` query always describe
    /// the same area (previously this fell back to a hardcoded Cupertino
    /// point while the map fell back to the hometown, so they disagreed).
    func searchCenter(_ session: SessionStore) -> CLLocationCoordinate2D {
        if LocationManager.shared.isLocationAuthorized,
           let loc = LocationManager.shared.location {
            return loc
        }
        let coords = session.user?.hometown?.coordinates ?? []
        if coords.count == 2 {
            return CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
        }
        return CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988)
    }
    
    init(
        searchText: String = "",
        events: [Event] = [Event](),
        tags: [Tag] = [Tag](),
        sports: [Sport] = [Sport](),
        radius: Double = 100,
        selectedTags: [String] = [String](),
        selectedSports: [String] = [String](),
        // Default to `.loading` so the explorer shows skeleton templates
        // on first launch instead of flashing the empty-state illustration
        // before the initial fetch resolves.
        state: VIEW_STATE = .loading,
        page: EVENT_EXPLORER_STATE = .events,
        lastUpdate: Date? = nil
    ) {
        self.searchText = searchText
        self.events = events
        self.tags = tags
        self.sports = sports
        self.radius = radius
        self.selectedTags = selectedTags
        self.selectedSports = selectedSports
        self.eventsState = state
        self.venuesState = state
        self.page = page
        self.lastUpdate = lastUpdate
        
        guard let r = self.searchRadius else { return }
        // Lets cap radius at 100 miles for now
        if r <= 100 {
            self.radius = r
        } else {
            self.radius = 100
            self.searchRadius = 100
        }
    }
    
    func selectSport(_ sport: Sport) {
        let name = sport.name
        if selectedSports.contains(name) {
            selectedSports.removeAll { $0 == name }
        } else {
            selectedSports.append(name)
        }
    }
    
    func isSportSelected(_ sport: Sport) -> Bool {
        return selectedSports.contains(sport.name)
    }
    
    func getSportsString() -> String {
        return selectedSports.joined(separator: ",")
    }
    
    func selectTag(_ tag: Tag) {
        let name = tag.name
        if selectedTags.contains(name) {
            selectedTags.removeAll { $0 == name }
        } else {
            selectedTags.append(name)
        }
    }
    
    func isTagSelected(_ tag: Tag) -> Bool {
        return selectedTags.contains(tag.name)
    }
    
    func getTagsString() -> String {
        return selectedTags.joined(separator: ",")
    }

    /// Reconcile the filter selections after the filter sheet is
    /// dismissed, for whichever page is currently active.
    ///
    /// The cache (`session.events` / `session.venues`) only ever grows —
    /// loaders insert/merge, never evict — and filters narrow it to the
    /// subset the user wants. So the decision is:
    ///
    /// - **A filter added** (a selection that wasn't applied before): the
    ///   server may hold matching items we haven't cached yet, so we
    ///   fetch and merge the difference into the cache.
    /// - **All filters cleared** (going from some selections to none):
    ///   the user now wants *everything*, but the cache may only hold the
    ///   previously-filtered subsets — so re-fetch the full set.
    /// - **Radius changed** (in either direction): the search area moved,
    ///   so we re-fetch. There's no client-side distance filtering, so a
    ///   smaller radius can't be honored locally — both grow and shrink
    ///   go to the network for an authoritative result set.
    /// - **A filter partially removed** (some still remain → the new
    ///   selection is a subset of the old): no network needed. The data
    ///   is already cached and the view's local `computeEvents` /
    ///   `computeVenues` filters re-narrow it once we adopt the new
    ///   selections below.
    ///
    /// Only the resource backing the active page is refetched, and only
    /// for the filters that apply to it (venues filter by sports only —
    /// the tags block is hidden on the venues page).
    func applyFilterChanges(from manager: SearchManager, in session: SessionStore) async {
        let oldTags = Set(selectedTags)
        let oldSports = Set(selectedSports)
        let newTags = Set(manager.selectedTags)
        let newSports = Set(manager.selectedSports)
        // Capture before adopting `manager.radius` below.
        let radiusChanged = manager.radius != radius

        // Adopt the new selections regardless of additions vs. removals —
        // the local filters key off these, so a partial removal still
        // re-narrows the visible list without a fetch.
        selectedTags = manager.selectedTags
        selectedSports = manager.selectedSports
        radius = manager.radius

        switch page {
        case .events:
            let added = !newTags.isSubset(of: oldTags) || !newSports.isSubset(of: oldSports)
            let clearedAll = newTags.isEmpty && newSports.isEmpty
                && (!oldTags.isEmpty || !oldSports.isEmpty)
            guard added || clearedAll || radiusChanged else { return }
            await fetchEvents(session, force: true)
        case .venues:
            let added = !newSports.isSubset(of: oldSports)
            let clearedAll = newSports.isEmpty && !oldSports.isEmpty
            guard added || clearedAll || radiusChanged else { return }
            await fetchVenues(session, force: true)
        }
    }

    func fetchEvents(_ session: SessionStore, force: Bool = false) async {
        // Skip if the throttle hasn't elapsed; bypass with `force: true`.
        if !force, let update = lastUpdate, Date().timeIntervalSince(update) < 300 {
            return
        }
        eventsState = .loading
        eventsState = await loadEvents(session) ? .success : .failure
    }

    /// Fetch both venues and events in parallel. Manages `state` itself so
    /// the inner loaders stay state-free — running them through the public
    /// `fetchEvents` / `fetchVenues` here would race two `state` writers
    /// (and flip between `.failure` and `.success` mid-load).
    func fetchData(_ session: SessionStore, force: Bool = false) async {
        // Both throttles get checked here so a recent partial refresh can
        // skip the network entirely without burning a `.loading` flash.
        let eventsThrottled = !force && (lastUpdate.map { Date().timeIntervalSince($0) < 300 } ?? false)
        let venuesThrottled = !force && (lastVenuesUpdate.map { Date().timeIntervalSince($0) < 300 } ?? false)
        if eventsThrottled && venuesThrottled { return }

        // Only flip a resource to `.loading` when we're actually about to
        // fetch it — a throttled resource keeps its prior (cached) state.
        if !eventsThrottled { eventsState = .loading }
        if !venuesThrottled { venuesState = .loading }

        async let eventsResult: Bool = eventsThrottled ? true : loadEvents(session)
        async let venuesResult: Bool = venuesThrottled ? true : loadVenues(session)
        let (eOK, vOK) = await (eventsResult, venuesResult)

        if !eventsThrottled { eventsState = eOK ? .success : .failure }
        if !venuesThrottled { venuesState = vOK ? .success : .failure }
    }

    /// Re-fetch whichever resource(s) are currently in a `.failure` state.
    /// Driven by the explorer's error-state "Try Again" button: if both
    /// events and venues failed, both are retried in parallel; if only one
    /// failed, only that one is retried. Bypasses the throttle since the
    /// user is explicitly asking for fresh data.
    func retry(_ session: SessionStore) async {
        let retryEvents = eventsState == .failure
        let retryVenues = venuesState == .failure

        // Nothing to do if neither resource is in a failed state.
        guard retryEvents || retryVenues else { return }

        if retryEvents { eventsState = .loading }
        if retryVenues { venuesState = .loading }

        async let eventsResult: Bool = retryEvents ? loadEvents(session) : true
        async let venuesResult: Bool = retryVenues ? loadVenues(session) : true
        let (eOK, vOK) = await (eventsResult, venuesResult)

        if retryEvents { eventsState = eOK ? .success : .failure }
        if retryVenues { venuesState = vOK ? .success : .failure }
    }

    /// Fetch venues near the current location, optionally filtered by the
    /// currently-selected sports. Mirrors `fetchEvents` — same 5-minute
    /// throttle, same state-machine, results are merged into
    /// `session.venues` (de-duped by id so re-fetches refresh stale entries
    /// in place rather than appending duplicates).
    func fetchVenues(_ session: SessionStore, force: Bool = false) async {
        if !force, let update = lastVenuesUpdate, Date().timeIntervalSince(update) < 300 {
            return
        }
        venuesState = .loading
        venuesState = await loadVenues(session) ? .success : .failure
    }

    // MARK: - Internal loaders
    //
    // These do the I/O + cache write and return whether the call succeeded.
    // They never touch `state`, so the public methods (and `fetchData`) are
    // free to coordinate state transitions without racing with each other.

    private func loadEvents(_ session: SessionStore) async -> Bool {
        let tagsString: String? = selectedTags.isEmpty ? nil : getTagsString()
        let sportsString: String? = selectedSports.isEmpty ? nil : getSportsString()

        // The server expects the radius in meters; `radius` is stored
        // canonically in miles, so convert before sending — matching the
        // venues fetch.
        let center = searchCenter(session)
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: center.longitude,
            latitude: center.latitude,
            radius: milesToMeters(radius: radius),
            tags: tagsString,
            sports: sportsString
        ) else {
            return false
        }

        lastUpdate = Date()
        resp.forEach { session.events.insert($0) }

        // Batch-hydrate venue descriptors that don't carry their own name.
        // Previously each `EventListItem` ran its own `.task` to fetch the
        // missing venues, producing N parallel requests on first show; this
        // collapses them into one deduped pass keyed by venue id.
        var seenIDs = Set<String>()
        var missing: [VenueDescriptor] = []
        for event in resp {
            for descriptor in event.venues {
                // Already has a usable name on the descriptor itself.
                if descriptor.name != nil { continue }
                // Need an id to fetch the full venue.
                guard let id = descriptor.id, !seenIDs.contains(id) else { continue }
                // Skip if the cache already has it.
                if session.venues.contains(where: { $0.id == id }) { continue }
                seenIDs.insert(id)
                missing.append(descriptor)
            }
        }
        if !missing.isEmpty {
            _ = await session.fetchVenues(in: missing)
        }
        return true
    }

    private func loadVenues(_ session: SessionStore) async -> Bool {
        // FieldObserver expects a non-optional sports string — empty means
        // "no sport filter". Reusing `getSportsString()` keeps the join
        // format consistent with the events filter.
        let sportsString = selectedSports.isEmpty ? "" : getSportsString()

        // The venue service expects the radius in meters; the slider value
        // (`radius`) is in miles, so convert — matching the events fetch.
        let radiusInMeters = Int(milesToMeters(radius: radius))

        let center = searchCenter(session)
        guard let resp = await session.fieldObserver.fetchVenues(
            longitude: center.longitude,
            latitude: center.latitude,
            radius: radiusInMeters,
            sports: sportsString
        ) else {
            return false
        }

        lastVenuesUpdate = Date()

        // Merge into the cache, replacing any existing entry with the
        // freshly-fetched one so updated venue data wins on refresh.
        for venue in resp {
            if let idx = session.venues.firstIndex(where: { $0.id == venue.id }) {
                session.venues[idx] = venue
            } else {
                session.venues.append(venue)
            }
        }
        return true
    }
}
