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
private let kVenueUnitPolygonZoomThreshold: Double = 0.009

/// One outer-ring polygon ready for `MapPolygon`. We flatten Polygon /
/// MultiPolygon geometries into this so a single `ForEach` can render them
/// inside the map's content builder.
private struct VenueUnitFootprint: Identifiable {
    /// Composite of `<unitID>-<polygonIndex>` so MultiPolygon rings stay
    /// uniquely identifiable.
    let id: String
    let coordinates: [CLLocationCoordinate2D]
}

/// A bucket of events that collapse into a single annotation at the
/// current zoom. Single-event clusters render as `EventAnnotation`;
/// multi-event clusters render as `EventClusterAnnotation`.
private struct EventCluster: Identifiable {
    let id: String   // grid-cell key, stable across rebuilds
    let coordinate: CLLocationCoordinate2D
    let events: [Event]
}

/// Same shape as `EventCluster` but for venue pins.
private struct VenueClusterItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let venues: [Venue]
}

/// Number of grid cells per screen-height of latitude. Tuned so that
/// items within ~1/12 of the visible map (≈ a thumb-width on screen)
/// collapse into a cluster. Larger numbers → less aggressive clustering.
private let kClusterCellsPerScreen: Double = 12

struct EventsExplorer: View {

    @Binding var router: EventRouter
    @Binding var showMenu: Bool
    @Binding var showNewEvent: Bool

    // Both of these come from the parent `Events` view so the explorer,
    // the filter sheet, and the bottom-sheet `ExplorerList` all read /
    // write the same state. Previously each owned a private copy, which
    // is why a fetch driven from the parent never moved the explorer's
    // `state` out of `.pending` etc.
    @Environment(EventsViewModel.self) private var viewModel
    @Environment(SearchManager.self) private var manager

    /// Camera position. Switched into `.userLocation(fallback:)` on first
    /// appear so the map opens centered on the user as soon as Core
    /// Location reports a fix; the fallback region (hometown → NYC) covers
    /// the moments before that or when permission is denied. The user
    /// breaks out of follow mode automatically by panning.
    @State private var camera: MapCameraPosition = .automatic

    /// Latest camera span — drives the unit-polygon visibility threshold.
    @State private var cameraLatitudeSpan: Double = 0.05

    /// Mobile-only: whether the bottom-sheet explorer is up. We dismiss
    /// it whenever the user pushes onto the navigation stack so the
    /// pushed detail view gets the full screen, then bring it back when
    /// the stack empties out (i.e. they popped back to the explorer).
    @State private var showExplorerSheet: Bool = true

    /// Memoized cluster results. Recomputing the grid on every body
    /// re-evaluation showed up in profiling — these caches are only
    /// invalidated when the underlying inputs (counts + zoom bucket)
    /// actually change, via the `.onChange(initial: true)` modifiers
    /// on `mapView`.
    @State private var cachedEventClusters: [EventCluster] = []
    @State private var cachedVenueClusters: [VenueClusterItem] = []

    @Environment(SessionStore.self) private var session
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Namespace private var namespace

    // The two environment-injected `@Observable`s above can't directly
    // produce SwiftUI `Binding`s, so the body re-derives them via
    // `@Bindable` (see body's first line).

    // MARK: - Derived data

    /// Events to drop pins for on the events tab.
    ///
    /// Inclusion rule mirrors the previous logic: the user is a participant
    /// (RSVPed → always show, since `hideLocation` is the "hide pre-RSVP"
    /// flag), OR the event isn't `.Private` AND `config.hideLocation != true`.
    /// We pull the coordinate straight off the event's first
    /// `VenueDescriptor.location` so events render even when the
    /// corresponding `Venue` hasn't landed in the session cache yet.
    private var visibleEvents: [Event] {
        let userID = session.user?.userID
        return Array(session.events).filter { event in
            let userIsParticipant: Bool = {
                guard let id = userID else { return false }
                return event.participants.contains(where: { $0.user?.userID == id })
            }()
            let isPrivate = event.visibility == .Private
            let locationHidden = event.config?.hideLocation == true
            return userIsParticipant || (!isPrivate && !locationHidden)
        }
    }

    /// Unit footprints to render. Empty unless we're on the venues tab AND
    /// the user has zoomed in past the threshold.
    private var visibleUnitFootprints: [VenueUnitFootprint] {
        guard viewModel.page == .venues,
              cameraLatitudeSpan < kVenueUnitPolygonZoomThreshold else {
            return []
        }
        return footprints(for: session.venues)
    }

    /// Coordinate to drop a pin at for an event. Prefers the event's first
    /// `VenueDescriptor.location` (the embedded snapshot the backend ships
    /// with the event), falling back to the cached `Venue` when the
    /// descriptor lacks coordinates.
    private func eventCoordinate(for event: Event) -> CLLocationCoordinate2D? {
        for descriptor in event.venues {
            // 1. Embedded location on the descriptor — most common case.
            if let loc = descriptor.location {
                let coords = loc.coordinates
                if coords.count >= 2 {
                    return CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
                }
            }
            // 2. Look up the resolved venue in the cache.
            if let id = descriptor.id,
               let venue = session.venues.first(where: { $0.id == id }) {
                let coords = venue.location.coordinates
                if coords.count >= 2 {
                    return CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
                }
            }
        }
        return nil
    }

    /// Snapped span used as the zoom-component of the cluster cache key.
    /// Rounding to 3 decimal places means tiny camera jitter doesn't
    /// invalidate the cache — clusters refresh only when the user
    /// meaningfully zooms in or out.
    private var snappedClusterSpan: Double {
        (cameraLatitudeSpan * 1000).rounded() / 1000
    }

    /// Inputs that, when changed, force a recompute of the events
    /// cluster grid: events count + the user's id (they may not be
    /// participating yet, then RSVP) + the zoom bucket.
    private var eventsClusterKey: String {
        "\(session.events.count)|\(session.user?.userID ?? "")|\(snappedClusterSpan)"
    }

    /// Same idea for venues, but no user-id dependency.
    private var venuesClusterKey: String {
        "\(session.venues.count)|\(snappedClusterSpan)"
    }

    /// Build the events cluster grid from the current state. Called only
    /// when `eventsClusterKey` changes (see `.onChange(initial: true)`),
    /// not on every body render.
    private func computeEventClusters() -> [EventCluster] {
        // Floor on cell size: prevents the grid from collapsing to zero
        // when the camera is at maximum zoom and `cameraLatitudeSpan`
        // approaches the span of a single building.
        let cellSize = max(cameraLatitudeSpan / kClusterCellsPerScreen, 0.0005)

        // Bucket: grid key → events + coordinates contributing to it.
        var buckets: [String: [(event: Event, coord: CLLocationCoordinate2D)]] = [:]

        for event in visibleEvents {
            guard let coord = eventCoordinate(for: event) else { continue }
            // Snap each coordinate to its grid cell. Using `.down` keeps
            // adjacent points stable as the camera shifts (vs. `.toNearest`
            // which would flicker pins across cell boundaries).
            let bucketLat = (coord.latitude / cellSize).rounded(.down) * cellSize
            let bucketLng = (coord.longitude / cellSize).rounded(.down) * cellSize
            // Round the key string aggressively so floating-point jitter
            // doesn't produce two effectively-identical keys.
            let key = String(format: "%.6f,%.6f", bucketLat, bucketLng)
            buckets[key, default: []].append((event, coord))
        }

        return buckets.map { (key, items) -> EventCluster in
            let lats = items.map { $0.coord.latitude }
            let lngs = items.map { $0.coord.longitude }
            let centerLat = lats.reduce(0, +) / Double(lats.count)
            let centerLng = lngs.reduce(0, +) / Double(lngs.count)
            return EventCluster(
                id: key,
                coordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                events: items.map(\.event)
            )
        }
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

    /// Tapping a cluster smoothly zooms the camera in toward its centroid
    /// — once the new span drops below the per-cell threshold the cluster
    /// will naturally split into individual pins on the next render.
    private func zoomToCluster(at coordinate: CLLocationCoordinate2D) {
        let zoomedSpan = max(cameraLatitudeSpan / 3, 0.0008)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: zoomedSpan, longitudeDelta: zoomedSpan)
        )
        withAnimation { camera = .region(region) }
    }

    /// Pin coordinate for a venue. Uses the Point shim on `GeoJSON.coordinates`;
    /// returns `nil` when the venue lacks a usable Point (e.g. polygon-only
    /// data) so we can skip rendering an off-coast pin.
    private func venueCoordinate(for venue: Venue) -> CLLocationCoordinate2D? {
        let coords = venue.location.coordinates
        guard coords.count >= 2 else { return nil }
        return CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
    }

    /// Same grid-bucketing approach as `computeEventClusters`, for
    /// venues. Single-venue cells render as full `VenueAnnotation`s;
    /// multi-venue cells render as a `+N` `VenueClusterAnnotation`.
    /// Memoized through `cachedVenueClusters`.
    private func computeVenueClusters() -> [VenueClusterItem] {
        let cellSize = max(cameraLatitudeSpan / kClusterCellsPerScreen, 0.0005)
        var buckets: [String: [(venue: Venue, coord: CLLocationCoordinate2D)]] = [:]

        for venue in session.venues {
            guard let coord = venueCoordinate(for: venue) else { continue }
            let bucketLat = (coord.latitude / cellSize).rounded(.down) * cellSize
            let bucketLng = (coord.longitude / cellSize).rounded(.down) * cellSize
            let key = String(format: "%.6f,%.6f", bucketLat, bucketLng)
            buckets[key, default: []].append((venue, coord))
        }

        return buckets.map { (key, items) -> VenueClusterItem in
            let lats = items.map { $0.coord.latitude }
            let lngs = items.map { $0.coord.longitude }
            let centerLat = lats.reduce(0, +) / Double(lats.count)
            let centerLng = lngs.reduce(0, +) / Double(lngs.count)
            return VenueClusterItem(
                id: key,
                coordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                venues: items.map(\.venue)
            )
        }
    }

    // MARK: - Map content
    //
    // Each tab gets its own `@MapContentBuilder` property so the pins are
    // sourced from the right collection — events read straight from
    // `session.events` (using the embedded `VenueDescriptor.location`)
    // instead of routing through the venue cache, which is why event
    // pins weren't showing up before: the descriptor → cached venue
    // lookup would silently fail when `session.venues` didn't contain
    // a matching id.

    @MapContentBuilder
    private var eventsMapContent: some MapContent {
        ForEach(cachedEventClusters) { cluster in
            // Single-event "cluster" → render the event's image directly.
            // Multi-event cluster → render a stacked-thumbnail badge with
            // a count chip so the user can tap to zoom in / disambiguate.
            Annotation(
                cluster.events.first?.title ?? "",
                coordinate: cluster.coordinate,
                anchor: .bottom
            ) {
                if cluster.events.count == 1, let event = cluster.events.first {
                    EventAnnotation(event: event)
                        // Tapping a single-event pin pushes the event
                        // detail onto the parent `NavigationStack` via
                        // the shared router.
                        .onTapGesture { router.navigate(to: .event(event: event)) }
                } else {
                    EventClusterAnnotation(events: cluster.events)
                        // Tapping a cluster zooms in toward its centroid;
                        // splitting the cluster automatically once the
                        // camera span drops below the cell threshold.
                        .onTapGesture { zoomToCluster(at: cluster.coordinate) }
                }
            }
            .annotationTitles(.hidden)
        }
    }

    @MapContentBuilder
    private var venuesMapContent: some MapContent {
        ForEach(cachedVenueClusters) { cluster in
            Annotation(
                cluster.venues.first?.name ?? "",
                coordinate: cluster.coordinate,
                anchor: .bottom
            ) {
                if cluster.venues.count == 1, let venue = cluster.venues.first {
                    VenueAnnotation(venue: venue)
                        .environment(session)
                        .onTapGesture { router.navigate(to: .venue(venue: venue)) }
                } else {
                    VenueClusterAnnotation(venues: cluster.venues)
                        .onTapGesture { zoomToCluster(at: cluster.coordinate) }
                }
            }
            .annotationTitles(.hidden)
        }

        // Unit polygons (only when zoomed in close).
        ForEach(visibleUnitFootprints) { footprint in
            MapPolygon(coordinates: footprint.coordinates)
                .foregroundStyle(.colorPrime.opacity(0.25))
                .stroke(.colorPrime, lineWidth: 1.5)
        }
    }

    // MARK: - Map view
    //
    // Computed (not stored in a `let`) so SwiftUI re-evaluates the
    // `MapContentBuilder` closure each time `body` runs.

    @ViewBuilder
    private var mapView: some View {
        Map(position: $camera) {
            // System blue dot.
            UserAnnotation()

            // Switch the pin source by the active tab. `if/else` rather
            // than `switch` for `MapContentBuilder` compatibility.
            if viewModel.page == .events {
                eventsMapContent
            } else {
                venuesMapContent
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            cameraLatitudeSpan = context.region.span.latitudeDelta
        }
        // Refresh the cluster caches when their inputs change.
        // `initial: true` makes it fire once on first appear so the
        // caches are populated before the user starts panning.
        .onChange(of: eventsClusterKey, initial: true) { _, _ in
            cachedEventClusters = computeEventClusters()
        }
        .onChange(of: venuesClusterKey, initial: true) { _, _ in
            cachedVenueClusters = computeVenueClusters()
        }
        .onAppear {
            if case .automatic = camera {
                camera = .userLocation(fallback: .region(session.currentLocation))
            }
        }
    }

    // MARK: - Body

    var body: some View {
        // `@Bindable` re-derives a `Binding` over an `@Observable`
        // sourced from the environment — needed because `$viewModel...`
        // doesn't compile on `@Environment`-injected observables.
        @Bindable var viewModel = viewModel

        switch horizontalSizeClass {
        case .regular: // iPad
            HStack {
                mapView

                // Environment values are inherited automatically; no
                // need to re-inject `session`/`manager`/`viewModel` here.
                ExplorerList(searchText: $viewModel.searchText, router: router, scale: 2)
                    .frame(maxWidth: SCREEN_WIDTH/2.5)
            }
        default:
            mapView
                .sheet(isPresented: $showExplorerSheet) {
                    // Pass the parent's router into the sheet so the list
                    // items push onto the underlying NavigationStack
                    // (NavigationLink alone can't reach across a sheet
                    // boundary). Sheet content does *not* inherit the
                    // host view's environment automatically, so the
                    // three injections below stay.
                    ExplorerList(searchText: $viewModel.searchText, router: router)
                        .environment(session)
                        .environment(manager)
                        .environment(viewModel)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.height(100), .medium, .large])
                        // Zillow-style: let map gestures pass through the
                        // sheet's backdrop while the user is at the small
                        // or medium detents. At `.large` the sheet covers
                        // the map fully so we let it behave modally.
                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                        // The sheet is the explorer surface — it should
                        // never get accidentally dismissed by a swipe-down
                        // (there's no "no sheet" state for this screen).
                        .interactiveDismissDisabled()
                        // Scrolls inside the list shouldn't drag the
                        // sheet up; the user resizes it via the grabber.
                        .presentationContentInteraction(.scrolls)
                }
                // Hide the explorer sheet whenever a detail page is
                // pushed onto the stack and bring it back on pop. We key
                // off `navPath.count` directly because `NavigationPath`
                // isn't `Equatable` — count changes on every push/pop.
                .onChange(of: router.navPath.count) { _, newCount in
                    showExplorerSheet = (newCount == 0)
                }
        }
    }
}

#Preview {
    EventsExplorer(router: .constant(EventRouter()), showMenu: .constant(false), showNewEvent: .constant(false))
        .environment(SessionStore())
        .environment(SearchManager())
        .environment(EventsViewModel())
}
