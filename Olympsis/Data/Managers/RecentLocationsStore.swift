//
//  RecentLocationsStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/2/26.
//

import Foundation

/// Persists the locations a user has recently chosen for an event so they can be
/// re-selected quickly the next time they open the location picker.
///
/// The list is stored in `UserDefaults` as JSON and capped at `maxStored`. Custom
/// (map-dropped) locations are kept alongside vetted venues, since `Venue` is the
/// common currency of the picker.
///
/// Marked `@Observable` so SwiftUI views that read `recents` re-render when a new
/// location is recorded or one is removed.
@Observable
final class RecentLocationsStore {

    /// Shared instance so every venue picker reads and writes the same history.
    static let shared = RecentLocationsStore()

    /// The most-recently-used locations, newest first.
    private(set) var recents: [Venue] = []

    /// UserDefaults key backing the persisted list.
    private let storageKey = "recent_event_locations"

    /// Maximum number of locations we keep on disk. The UI shows the first few
    /// with a "Show more" affordance to reveal the rest.
    private let maxStored = 20

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    /// Records a chosen location, moving it to the front and de-duplicating.
    ///
    /// `Venue` equality matches on `id` OR (`name` + `location`), so picking the
    /// same place twice collapses into a single, most-recent entry rather than
    /// stacking duplicates.
    func record(_ venue: Venue) {
        recents.removeAll { $0 == venue }
        recents.insert(venue, at: 0)
        if recents.count > maxStored {
            recents = Array(recents.prefix(maxStored))
        }
        persist()
    }

    /// Removes a single location from the history. Backs the trailing "x" on each
    /// recent row so users can clear entries they no longer want suggested.
    func remove(_ venue: Venue) {
        recents.removeAll { $0 == venue }
        persist()
    }

    // MARK: - Persistence

    /// Loads the persisted list on init. A decode failure (e.g. an old/incompatible
    /// payload) is treated as "no history" rather than crashing.
    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let stored = try? JSONDecoder().decode([Venue].self, from: data) else {
            return
        }
        recents = stored
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(recents) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
