//
//  RecentInviteesCache.swift
//  Olympsis
//
//  Created by Claude on 7/4/26.
//

import os
import Foundation

/// A small persistence helper that remembers the users you've most recently
/// invited to events. Backed by `UserDefaults` (matching `CacheService`), it
/// keeps a most-recent-first list of `UserSnippet`s capped at `maxCount` (100).
///
/// The event invitee picker reads this list to offer quick re-invites and
/// records each new selection here so it bubbles to the top next time.
final class RecentInviteesCache {

    /// Maximum number of recently-invited users to retain.
    static let maxCount = 100

    private let key = "recent_invitees"
    private let log = Logger(subsystem: "com.olympsis.client", category: "recent_invitees_cache")

    private let defaults = UserDefaults()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// Returns the cached recently-invited users, most recent first.
    func fetch() -> [UserSnippet] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try decoder.decode([UserSnippet].self, from: data)
        } catch {
            log.error("Failed to decode recent invitees: \(error.localizedDescription)")
            return []
        }
    }

    /// Records a newly-invited user, moving it to the front of the list.
    ///
    /// Any existing entry for the same user is removed first so we don't store
    /// duplicates, then the list is trimmed to `maxCount`.
    func record(_ user: UserSnippet) {
        guard let userID = user.userID else { return }

        var recents = fetch()
        recents.removeAll { $0.userID == userID }
        recents.insert(user, at: 0)

        if recents.count > RecentInviteesCache.maxCount {
            recents = Array(recents.prefix(RecentInviteesCache.maxCount))
        }

        persist(recents)
    }

    /// Persists the given list, encoding it to `UserDefaults`.
    private func persist(_ recents: [UserSnippet]) {
        do {
            let data = try encoder.encode(recents)
            defaults.set(data, forKey: key)
        } catch {
            log.error("Failed to encode recent invitees: \(error.localizedDescription)")
        }
    }
}
