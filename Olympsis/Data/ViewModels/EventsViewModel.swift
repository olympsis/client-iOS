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
        // Return early to prevent frequent data refreshes
        if !force, let update = lastUpdate {
            if Date().timeIntervalSince(update) < 300 {
                return
            }
        }
        
        state = .loading
        
        var tagsString: String? = nil
        var sportsString: String? = nil
        
        if (!selectedTags.isEmpty) {
            tagsString = getTagsString()
        }
        
        if (!selectedSports.isEmpty) {
            sportsString = getSportsString()
        }
        
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: currentLocation.coordinate.longitude,
            latitude: currentLocation.coordinate.latitude,
            radius: radius,
            tags: tagsString,
            sports: sportsString) else {
            state = .failure
            return
        }
        
        lastUpdate = Date()
        resp.forEach { session.events.insert($0) }
        
        state = .success
    }
}
