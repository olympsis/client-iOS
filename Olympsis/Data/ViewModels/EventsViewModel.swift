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
    
    var state: VIEW_STATE = .loading
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
    
    init(
        searchText: String = "",
        events: [Event] = [Event](),
        tags: [Tag] = [Tag](),
        sports: [Sport] = [Sport](),
        radius: Double = 100,
        selectedTags: [String] = [String](),
        selectedSports: [String] = [String](),
        state: VIEW_STATE = .pending,
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
        self.state = state
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
    
    func fetchEvents(_ session: SessionStore, force: Bool = false) async {
        // Skip if the throttle hasn't elapsed; bypass with `force: true`.
        if !force, let update = lastUpdate, Date().timeIntervalSince(update) < 300 {
            return
        }
        state = .loading
        state = await loadEvents(session) ? .success : .failure
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

        state = .loading

        async let eventsResult: Bool = eventsThrottled ? true : loadEvents(session)
        async let venuesResult: Bool = venuesThrottled ? true : loadVenues(session)
        let (eOK, vOK) = await (eventsResult, venuesResult)
        
        state = (eOK && vOK) ? .success : .failure
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
        state = .loading
        state = await loadVenues(session) ? .success : .failure
    }

    // MARK: - Internal loaders
    //
    // These do the I/O + cache write and return whether the call succeeded.
    // They never touch `state`, so the public methods (and `fetchData`) are
    // free to coordinate state transitions without racing with each other.

    private func loadEvents(_ session: SessionStore) async -> Bool {
        let tagsString: String? = selectedTags.isEmpty ? nil : getTagsString()
        let sportsString: String? = selectedSports.isEmpty ? nil : getSportsString()

        guard let resp = await session.eventObserver.fetchEvents(
            longitude: currentLocation.coordinate.longitude,
            latitude: currentLocation.coordinate.latitude,
            radius: radius,
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

        guard let resp = await session.fieldObserver.fetchVenues(
            longitude: currentLocation.coordinate.longitude,
            latitude: currentLocation.coordinate.latitude,
            radius: Int(16000),
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
