//
//  VenueNeighborhoodIndex.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/11/26.
//

import SwiftUI

/// A neighborhood-grouped index of venues: a row of quick-jump chips at the
/// top (tap one to scroll to its section) followed by one section per
/// neighborhood — a header with the neighborhood name + venue count, then the
/// venues that belong to it.
///
/// Drop this inside a vertical `ScrollView`. It brings its own
/// `ScrollViewReader` so the chips can scroll the enclosing scroll view to a
/// section, but it deliberately does *not* add its own vertical `ScrollView`
/// so it composes inside whatever container the caller already has (the Home
/// "view all" sheet, the Events explorer drawer, etc.).
///
/// The grouping is cached in `@State` and only rebuilt when `venues` changes
/// (e.g. a filter is applied), rather than re-grouping/re-sorting on every
/// `body` evaluation.
struct VenueNeighborhoodIndex: View {

    /// Venues to group and display.
    let venues: [Venue]

    /// Card sizing passed through to each `VenueListItem`.
    var scale: LIST_ITEM_SCALE = .regular

    /// Per-venue tap handler. When `nil`, `VenueListItem` falls back to its
    /// own detail sheet (used by the Home "view all" sheet); the Events
    /// explorer passes a closure that routes onto the shared navigation stack.
    var onSelect: ((Venue) -> Void)? = nil

    /// Cached neighborhood index. See `groupByNeighborhood`.
    @State private var neighborhoods: [(name: String, venues: [Venue])] = []

    /// Pure grouping used to (re)build the cached `neighborhoods` index.
    /// Buckets venues by neighborhood, sorted alphabetically for a stable
    /// order. A venue's neighborhood is its `subLocality` (e.g. "Manhattan");
    /// when that's missing we fall back to the city and, as a last resort, an
    /// "Other" bucket so every venue still appears somewhere.
    private func groupByNeighborhood(_ venues: [Venue]) -> [(name: String, venues: [Venue])] {
        let grouped = Dictionary(grouping: venues) { venue -> String in
            if let hood = venue.subLocality, !hood.isEmpty { return hood }
            if !venue.city.isEmpty { return venue.city }
            return "Other"
        }
        return grouped
            .map { (name: $0.key, venues: $0.value) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        // Inner ScrollViewReader so the chips can scroll to a section. Its
        // proxy resolves `scrollTo` against the caller's enclosing vertical
        // ScrollView, so we don't need our own.
        ScrollViewReader { proxy in
            LazyVStack(alignment: .leading, spacing: 0) {
                // MARK: - Quick-jump chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(neighborhoods, id: \.name) { hood in
                            Button {
                                withAnimation {
                                    proxy.scrollTo(hood.name, anchor: .top)
                                }
                            } label: {
                                neighborhoodChip(hood)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // MARK: - Neighborhood sections
                ForEach(neighborhoods, id: \.name) { hood in
                    neighborhoodHeader(hood)
                        .id(hood.name)

                    ForEach(hood.venues) { venue in
                        VenueListItem(
                            venue: venue,
                            scale: scale,
                            onTap: onSelect.map { handler in
                                { handler(venue) }
                            }
                        )
                    }
                }
            }
            // Build the cache on first render (`initial: true`) and rebuild it
            // only when the venue set changes — e.g. after a filter.
            .onChange(of: venues, initial: true) { _, newValue in
                neighborhoods = groupByNeighborhood(newValue)
            }
        }
    }

    // MARK: - Subviews

    /// A tappable chip for the quick-jump row: neighborhood name plus its
    /// venue count, styled as a capsule.
    @ViewBuilder
    private func neighborhoodChip(_ hood: (name: String, venues: [Venue])) -> some View {
        Text("\(hood.name) (\(hood.venues.count))")
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.Background.secondary, in: Capsule())
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.border, lineWidth: 1)
            }
    }

    /// The section header for a neighborhood in the index: its name with a
    /// small count badge showing how many venues fall under it.
    @ViewBuilder
    private func neighborhoodHeader(_ hood: (name: String, venues: [Venue])) -> some View {
        HStack(spacing: 8) {
            Text(hood.name)
                .font(.title3)
                .bold()
                .foregroundStyle(Color.Text.headline)

            Text("\(hood.venues.count)")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.Text.subHeadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.Background.secondary, in: Capsule())

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
}

#Preview {
    ScrollView {
        VenueNeighborhoodIndex(venues: VENUES)
            .environment(SessionStore())
    }
}
