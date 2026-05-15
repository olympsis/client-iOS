//
//  SearchManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/30/25.
//

import MapKit
import SwiftUI
import Foundation

@Observable
class SearchManager {

    var tags: [Tag] = []
    var sports: [Sport] = []

    var radius: Double = 10
    var selectedTags: [String] = []
    var selectedSports: [String] = []
    var mapRegion: MKCoordinateRegion?

    @ObservationIgnored
    private let persistKey: String = "events"

    @ObservationIgnored
    @AppStorage("searchRadius") private var searchRadius: Double? // search radius for fields/events in meters

    init() {
        // Existing radius hydration — cap at 100 miles.
        if let r = searchRadius {
            if r <= 100 {
                radius = r
            } else {
                radius = 100
                searchRadius = 100
            }
        }

        // Hydrate persisted filter selections when a namespace is set.
        // If the keys are absent (first launch, or persistence disabled
        // for this instance) the arrays stay empty and the host view
        // decides whether to seed defaults — see `hasPersistedSelections`.
        if let sports = UserDefaults.standard.array(forKey: Self.sportsKey(for: persistKey)) as? [String] {
            selectedSports = sports
        }
        if let tags = UserDefaults.standard.array(forKey: Self.tagsKey(for: persistKey)) as? [String] {
            selectedTags = tags
        }
    }

    // MARK: - Persistence

    private static func sportsKey(for namespace: String) -> String {
        "\(namespace).selectedSports"
    }

    private static func tagsKey(for namespace: String) -> String {
        "\(namespace).selectedTags"
    }

    var hasPersistedSelections: Bool {
        return UserDefaults.standard.object(forKey: Self.sportsKey(for: persistKey)) != nil
            || UserDefaults.standard.object(forKey: Self.tagsKey(for: persistKey)) != nil
    }

    func persistSelections() {
        UserDefaults.standard.set(selectedSports, forKey: Self.sportsKey(for: persistKey))
        UserDefaults.standard.set(selectedTags, forKey: Self.tagsKey(for: persistKey))
    }

    // MARK: - Mutators

    func selectSport(_ sport: Sport) {
        let name = sport.name
        if selectedSports.contains(name) {
            selectedSports.removeAll { $0 == name }
        } else {
            selectedSports.append(name)
        }
        // Every individual add / remove is persisted immediately so a
        // mid-session app kill doesn't lose the user's filter edits.
        persistSelections()
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
        persistSelections()
    }

    func isTagSelected(_ tag: Tag) -> Bool {
        return selectedTags.contains(tag.name)
    }

    func getTagsString() -> String {
        return selectedTags.joined(separator: ",")
    }
}
