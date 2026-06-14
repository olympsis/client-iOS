//
//  ExplorerFiltering.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/14/26.
//

import Foundation

// Shared filtering for the events explorer. Both the drawer list
// (`ExplorerList`) and the map annotations (`EventsExplorer`) run their
// data through these so the two views can never disagree about what the
// active tag / sport / search filters include — previously the map
// ignored the filters entirely and kept showing every pin after the list
// had narrowed.

extension Sequence where Element == Event {

    /// Apply the explorer's active tag/sport selections and free-text
    /// search to a collection of events.
    ///
    /// Empty selections and an empty `search` needle are no-ops, so this is
    /// safe to call unconditionally. Tag/sport matching is "any selected
    /// value present on the event" (OR within a dimension, AND across
    /// dimensions); search matches the event title.
    func filteredForExplorer(tags: [String], sports: [String], search: String) -> [Event] {
        let needle = search.localizedLowercase
        return filter { event in
            let tagOK = tags.isEmpty || tags.contains { event.tags.contains($0) }
            let sportOK = sports.isEmpty || sports.contains { event.sports.contains($0) }
            let searchOK = needle.isEmpty || event.title.localizedLowercase.contains(needle)
            return tagOK && sportOK && searchOK
        }
    }
}

extension Sequence where Element == Venue {

    /// Venue counterpart of ``filteredForExplorer(tags:sports:search:)``.
    /// Venues only carry a `sports` array (the filter sheet hides the tags
    /// block on the venues page — see `FilterView(showTags:)`), so only
    /// sports + search apply; the needle matches the venue name, city, and
    /// neighborhood (`subLocality`).
    func filteredForExplorer(sports: [String], search: String) -> [Venue] {
        let needle = search.localizedLowercase
        return filter { venue in
            let sportOK = sports.isEmpty || sports.contains { venue.sports.contains($0) }
            let searchOK = needle.isEmpty
                || venue.name.localizedLowercase.contains(needle)
                || venue.city.localizedLowercase.contains(needle)
                || (venue.subLocality?.localizedLowercase.contains(needle) ?? false)
            return sportOK && searchOK
        }
    }
}
