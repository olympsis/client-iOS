//
//  EventsExplorer.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/2/26.
//

import MapKit
import SwiftUI

/// Threshold (in latitude degrees) below which we start rendering each venue's
/// unit polygons on top of its pin. ~0.003° ≈ 300 m N–S, i.e. the user has
/// zoomed in close enough that the unit footprints are large on screen.
private let kVenueUnitPolygonZoomThreshold: Double = 0.003

/// One outer-ring polygon ready for `MapPolygon`. We flatten Polygon /
/// MultiPolygon geometries into this so a single `ForEach` can render them
/// inside the map's content builder.
private struct VenueUnitFootprint: Identifiable {
    /// Composite of `<unitID>-<polygonIndex>` so MultiPolygon rings stay
    /// uniquely identifiable.
    let id: String
    let coordinates: [CLLocationCoordinate2D]
}

struct EventsExplorer: View {

    @Binding var router: EventRouter
    @Binding var showMenu: Bool
    @Binding var showNewEvent: Bool

    @State private var manager = SearchManager()
    @State private var viewModel = EventsViewModel()

    /// Camera position for the map. We start in `.userLocation` follow mode
    /// so the map opens centered on the user as soon as Core Location reports
    /// a fix; the fallback region (hometown → NYC) covers the moments before
    /// that or when location permission is denied. The user breaks out of
    /// follow mode automatically by panning.
    @State private var camera: MapCameraPosition = .automatic

    /// Latest camera span — used to decide whether unit polygons should be
    /// drawn. Updated via `onMapCameraChange`.
    @State private var cameraLatitudeSpan: Double = 0.05

    @Environment(SessionStore.self) private var session
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Namespace private var namespace

    // MARK: - Derived data

    /// Venues to drop pins for, depending on the picker selection.
    /// - `.events` → venues attached to events the current user has RSVPed
    ///   to AND whose `config.hideLocation` is not `true`.
    /// - `.venues` → every venue in the session cache.
    private var mapVenues: [Venue] {
        switch viewModel.page {
        case .events:
            return rsvpedEventVenues()
        case .venues:
            return session.venues
        }
    }

    /// Unit footprints to render. Empty unless we're on the venues tab AND
    /// the user has zoomed in past the threshold — pulling these onto the
    /// map at low zoom levels would just render as fuzzy dots.
    private var visibleUnitFootprints: [VenueUnitFootprint] {
        guard viewModel.page == .venues,
              cameraLatitudeSpan < kVenueUnitPolygonZoomThreshold else {
            return []
        }
        return footprints(for: mapVenues)
    }

    /// For the events tab: collect every venue referenced by an event the
    /// user can see on the map.
    ///
    /// Inclusion rule:
    /// - The user is a participant (they've RSVPed) — always show, since
    ///   `hideLocation` is the "hide pre-RSVP" flag and post-RSVP they're
    ///   entitled to the venue.
    /// - OR the event isn't `.Private` AND `config.hideLocation != true`.
    ///
    /// We resolve each `VenueDescriptor` against `session.venues` so we have
    /// full geo data for the pin; descriptors with no matching cached venue
    /// are dropped here and re-attempted by the hydration `.task` below.
    private func rsvpedEventVenues() -> [Venue] {
        let userID = session.user?.userID
        var seen = Set<String>()
        var result: [Venue] = []

        for event in session.events {
            let userIsParticipant: Bool = {
                guard let id = userID else { return false }
                return event.participants.contains(where: { $0.user?.userID == id })
            }()
            let isPrivate = event.visibility == .Private
            let locationHidden = event.config?.hideLocation == true

            let canShow = userIsParticipant || (!isPrivate && !locationHidden)
            guard canShow else { continue }

            for descriptor in event.venues {
                // Match by ID first (internal venues), then fall back to
                // name + coords for external / seed-style venues that come
                // through without a backend ID.
                let match = session.venues.first { venue in
                    if let id = descriptor.id, venue.id == id { return true }
                    if let name = descriptor.name, venue.name == name,
                       let loc = descriptor.location, loc == venue.location {
                        return true
                    }
                    return false
                }
                if let venue = match, !seen.contains(venue.id) {
                    seen.insert(venue.id)
                    result.append(venue)
                }
            }
        }
        return result
    }

    /// Flattens each unit's `Polygon` / `MultiPolygon` geometry into a list
    /// of `MapPolygon`-friendly footprints. Holes (inner rings) are skipped
    /// for now — only the outer ring of each polygon is drawn.
    private func footprints(for venues: [Venue]) -> [VenueUnitFootprint] {
        var out: [VenueUnitFootprint] = []
        for venue in venues {
            for unit in venue.units {
                switch unit.location.geometry {
                case .polygon(let rings):
                    if let outer = rings.first {
                        out.append(
                            VenueUnitFootprint(
                                id: "\(unit.id)-0",
                                coordinates: coordinates(from: outer)
                            )
                        )
                    }
                case .multiPolygon(let polygons):
                    for (idx, poly) in polygons.enumerated() {
                        if let outer = poly.first {
                            out.append(
                                VenueUnitFootprint(
                                    id: "\(unit.id)-\(idx)",
                                    coordinates: coordinates(from: outer)
                                )
                            )
                        }
                    }
                case .point, .lineString, .empty, .unknown:
                    continue
                }
            }
        }
        return out
    }

    /// GeoJSON stores positions as `[lng, lat]`; MapKit wants the inverse.
    private func coordinates(from ring: [[Double]]) -> [CLLocationCoordinate2D] {
        ring.compactMap { pair in
            guard pair.count >= 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[1], longitude: pair[0])
        }
    }

    /// For an event venue we may not have the full `Venue` object in cache
    /// yet — kick off a hydration pass for any descriptors that pass the
    /// same inclusion rule used by `rsvpedEventVenues()` so the pins show
    /// up as soon as the request resolves.
    @MainActor
    private func hydrateRsvpedVenuesIfNeeded() async {
        guard viewModel.page == .events else { return }
        let userID = session.user?.userID

        var missing: [VenueDescriptor] = []
        for event in session.events {
            let userIsParticipant: Bool = {
                guard let id = userID else { return false }
                return event.participants.contains(where: { $0.user?.userID == id })
            }()
            let isPrivate = event.visibility == .Private
            let locationHidden = event.config?.hideLocation == true
            let canShow = userIsParticipant || (!isPrivate && !locationHidden)
            guard canShow else { continue }

            for descriptor in event.venues {
                guard let id = descriptor.id else { continue }
                if !session.venues.contains(where: { $0.id == id }) {
                    missing.append(descriptor)
                }
            }
        }
        guard !missing.isEmpty else { return }
        _ = await session.fetchVenues(in: missing)
    }

    // MARK: - Body

    var body: some View {
        let map = Map(position: $camera) {
            // System-rendered blue dot for the user's current location.
            // Requires the Info.plist location-permission keys (already
            // configured for this app).
            UserAnnotation()

            ForEach(mapVenues, id: \.id) { venue in
                Annotation(
                    venue.name,
                    coordinate: pinCoordinate(for: venue),
                    anchor: .bottom
                ) {
                    VenueAnnotation(venue: venue)
                        .environment(session)
                }
            }

            ForEach(visibleUnitFootprints) { footprint in
                MapPolygon(coordinates: footprint.coordinates)
                    .foregroundStyle(.colorPrime.opacity(0.25))
                    .stroke(.colorPrime, lineWidth: 1.5)
            }
        }
        .mapControls {
            // Adds the standard "recenter on me" puck so the user can jump
            // back to their current location after panning around.
            MapUserLocationButton()
            MapCompass()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            cameraLatitudeSpan = context.region.span.latitudeDelta
        }
        // Re-key the hydration task on the events count too. The parent
        // `Events` view fetches events asynchronously into `session.events`
        // *after* `EventsExplorer` first appears, so a key of just
        // `viewModel.page` would fire once on the empty set and never again.
        // Including the count makes the task re-run whenever events arrive.
        .task(id: "\(viewModel.page.rawValue)-\(session.events.count)") {
            await hydrateRsvpedVenuesIfNeeded()
        }
        .onAppear {
            // Switch from `.automatic` into user-follow mode on first
            // appear. We can't initialize it that way at the property
            // declaration because `session.currentLocation` (the fallback)
            // isn't accessible there — `@Environment` isn't available in
            // property initializers. The follow mode breaks the moment the
            // user pans the map, so this is purely the launch behavior.
            if case .automatic = camera {
                camera = .userLocation(fallback: .region(session.currentLocation))
            }
        }

        switch horizontalSizeClass {
        case .regular: // iPad
            HStack {
                map

                // `scale: 2` flips `EventListItem` into its `.small` layout
                // so each card fits the narrower split-view column without
                // truncating titles / clipping the meta row.
                ExplorerList(searchText: $viewModel.searchText, scale: 2)
                    .frame(maxWidth: SCREEN_WIDTH/2.5)
                    .environment(session)
                    .environment(manager)
                    .environment(viewModel)
            }
        default:
            Group {
                map
            }.sheet(isPresented: .constant(true)) {
                ExplorerList(searchText: $viewModel.searchText)
                    .environment(session)
                    .environment(manager)
                    .environment(viewModel)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(100), .medium, .large])
            }
        }
    }

    /// Defensive coordinate extraction — `Venue.location.coordinates` is the
    /// Point shim from `GeoJSON`, which can be empty for unit-only or
    /// polygon-only venues. We fall back to (0, 0) in that case so the
    /// annotation still renders rather than crashing on an out-of-bounds
    /// access; the pin will be off-coast and harmless.
    private func pinCoordinate(for venue: Venue) -> CLLocationCoordinate2D {
        let coords = venue.location.coordinates
        guard coords.count >= 2 else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        return CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
    }
}

#Preview {
    EventsExplorer(router: .constant(EventRouter()), showMenu: .constant(false), showNewEvent: .constant(false))
        .environment(SessionStore())
}
