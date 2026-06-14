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

/// Integer grid-cell coordinate. Used as the bucketing key for the
/// cluster algorithm — `Hashable` on two `Int`s is roughly 10× faster
/// than `String(format: "%.6f,%.6f", ...)` and sidesteps the per-event
/// string allocation. Stable across rebuilds because the same point at
/// the same zoom always maps to the same `(lat, lng)` cell index.
private struct CellKey: Hashable {
    let lat: Int
    let lng: Int
}

/// A bucket of events that collapse into a single annotation at the
/// current zoom. Single-event clusters render as `EventAnnotation`;
/// multi-event clusters render as `EventClusterAnnotation`.
private struct EventCluster: Identifiable {
    let id: CellKey   // grid-cell key, stable across rebuilds
    let coordinate: CLLocationCoordinate2D
    let events: [Event]
}

/// Same shape as `EventCluster` but for venue pins.
private struct VenueClusterItem: Identifiable {
    let id: CellKey
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

    /// Last detent the user dragged the explorer drawer to. Persisted
    /// via `@AppStorage` so the drawer not only re-opens at the user's
    /// chosen position after they drill into a detail view and come
    /// back, but also remembers the position across app launches — if
    /// someone always works with the list fully expanded (`.large`),
    /// the explorer will open there next time too. Stored as the
    /// detent's raw string value (see `DrawerDetent`).
    @AppStorage("event_explorer_sheet_detent") private var sheetDetent: DrawerDetent = .medium

    /// Date the user last picked from either the in-drawer calendar
    /// or the floating-toolbar calendar. Lifted up here so both
    /// pickers share state and selecting from either scrolls the
    /// list to the same place.
    @State private var selectedDate: Date = Date()

    /// Memoized cluster results. Recomputing the grid on every body
    /// re-evaluation showed up in profiling — these caches are only
    /// invalidated when the underlying inputs (counts + zoom bucket)
    /// actually change, via the `.onChange(initial: true)` modifiers
    /// on `mapView`.
    @State private var cachedEventClusters: [EventCluster] = []
    @State private var cachedVenueClusters: [VenueClusterItem] = []

    /// Set when the user taps a multi-event cluster pin on the map.
    /// Drives the disambiguation sheet that lists the events grouped
    /// by day (same headers `ExplorerList` uses). `nil` while the
    /// sheet is dismissed.
    @State private var clusterSheet: ClusterEventsSheetData?

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

        // Bucket: integer grid-cell key → events + coordinates contributing to it.
        var buckets: [CellKey: [(event: Event, coord: CLLocationCoordinate2D)]] = [:]

        for event in visibleEvents {
            guard let coord = eventCoordinate(for: event) else { continue }
            // Snap each coordinate to its grid cell index. `Int(.rounded(.down))`
            // gives stable, jitter-free buckets that hash trivially.
            let bucketLat = Int((coord.latitude / cellSize).rounded(.down))
            let bucketLng = Int((coord.longitude / cellSize).rounded(.down))
            let key = CellKey(lat: bucketLat, lng: bucketLng)
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
        var buckets: [CellKey: [(venue: Venue, coord: CLLocationCoordinate2D)]] = [:]

        for venue in session.venues {
            guard let coord = venueCoordinate(for: venue) else { continue }
            let bucketLat = Int((coord.latitude / cellSize).rounded(.down))
            let bucketLng = Int((coord.longitude / cellSize).rounded(.down))
            let key = CellKey(lat: bucketLat, lng: bucketLng)
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

    /// When every event collapsed into a cluster belongs to the *same*
    /// recurring series — a backend-linked recurrence or a scraped
    /// same-title / same-coordinate series — the "+N" badge is misleading:
    /// the pins are all the same event repeating on different dates, not N
    /// different things to disambiguate. In that case we surface a single
    /// image pin for the soonest upcoming occurrence. Returns `nil` for any
    /// cluster that mixes series (or contains an unrelated one-off), so it
    /// falls back to the normal cluster badge.
    private func recurringRepresentative(for cluster: EventCluster) -> Event? {
        guard cluster.events.count > 1 else { return nil }
        let keys = cluster.events.map { $0.recurringSeriesKey }
        // All events must carry the *same, non-nil* key to count as one
        // series. `keys.first` is doubly-optional (optional element of the
        // array, itself an optional key); `?? nil` flattens it.
        guard let key = keys.first ?? nil, keys.allSatisfy({ $0 == key }) else {
            return nil
        }
        return cluster.events.soonestUpcoming()
    }

    @MapContentBuilder
    private var eventsMapContent: some MapContent {
        ForEach(cachedEventClusters) { cluster in
            Annotation(
                cluster.events.first?.title ?? "",
                coordinate: cluster.coordinate,
                anchor: .bottom
            ) {
                if cluster.events.count == 1, let event = cluster.events.first {
                    EventAnnotation(event: event)
                        .onTapGesture { router.navigate(to: .event(event: event)) }
                } else if let representative = recurringRepresentative(for: cluster) {
                    // Same recurring event repeating at this spot — show one
                    // clean image pin for the next occurrence instead of a
                    // "+N" badge. The event detail surfaces the other dates.
                    EventAnnotation(event: representative)
                        .onTapGesture { router.navigate(to: .event(event: representative)) }
                } else {
                    EventClusterAnnotation(events: cluster.events)
                        .onTapGesture {
                            clusterSheet = ClusterEventsSheetData(events: cluster.events)
                        }
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

    @ViewBuilder
    private var mapView: some View {
        Map(position: $camera) {
            // System blue dot.
            UserAnnotation()

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
        .onChange(of: eventsClusterKey, initial: true) { _, _ in
            cachedEventClusters = computeEventClusters()
        }
        .onChange(of: venuesClusterKey, initial: true) { _, _ in
            cachedVenueClusters = computeVenueClusters()
        }
        .task {
            // Don't fight the user if they've already panned away.
            guard case .automatic = camera else { return }
            _ = await LocationManager.shared.waitForLocation(timeout: 1.0)
            withAnimation { camera = .region(session.currentLocation) }
        }
    }

    // MARK: - Body

    var body: some View {
        @Bindable var viewModel = viewModel

        // `Group` wrapper exists so the `.sheet(item:)` for the
        // cluster disambiguation list can attach once across both
        // size classes rather than being duplicated on each branch.
        Group {
        switch horizontalSizeClass {
        case .regular: // iPad
            // Layout shift from the old `HStack { map, list }`:
            //   • `mapView` is now the root and spans the full width.
            //   • `ExplorerList` is attached as a trailing
            //     `.safeAreaInset` so the map renders *behind* it,
            //     letting the iOS 26 glass material pick up the live
            //     map through the panel.
            //   • System `MapCompass` / `MapUserLocationButton` and the
            //     floating chip column follow the inset map's safe
            //     area, so they sit on the visible map portion to the
            //     left of the panel rather than hiding behind it.
            mapView
                .overlay(alignment: .topTrailing) {
                    FloatingDrawerActions(
                        selectedDate: $selectedDate,
                        showMenu: $showMenu,
                        numFiltersActive: viewModel.numFiltersActive,
                        showCalendar: viewModel.page == .events,
                        axis: .vertical
                    )
                    .padding(.top, 120)
                    // `.safeAreaInset(edge: .trailing)` below already
                    // shrinks `mapView`'s effective frame so that its
                    // trailing edge sits flush against the glass panel.
                    // The overlay anchors to that inner frame, so 13pt
                    // is enough to match MapKit's own control inset —
                    // no need to subtract the panel width here.
                    .padding(.trailing, 13)
                }
                .safeAreaInset(edge: .trailing, spacing: 0) {
                    // Expanded set to false to prevent filter & date
                    // buttons from squishing out the view page picker.
                    ExplorerList(
                        searchText: $viewModel.searchText,
                        router: router,
                        showMenu: $showMenu,
                        selectedDate: $selectedDate,
                        isFullyExpanded: false,
                        scale: 2
                    )
                    .frame(width: SCREEN_WIDTH/2.3)
                    .background {
                        // iOS 26: liquid-glass surface — the
                        // full-width map underneath blurs through.
                        // Older systems get an opaque `systemBackground`
                        // since `glassEffect(_:in:)` is iOS 26+ only.
                        if #available(iOS 26.0, *) {
                            Color.clear
                                .glassEffect(.regular, in: .rect)
                                .ignoresSafeArea()
                        } else {
                            Color(uiColor: .systemBackground)
                                .ignoresSafeArea()
                        }
                    }
                }
        default:
            // ZStack lets us decouple keyboard avoidance per-layer:
            //  • Layer 1 (map + drawer) ignores `.keyboard` so its
            //    frame doesn't shrink when the keyboard appears —
            //    without this, the overlay's bottom edge moves up
            //    with the keyboard and drags the whole drawer (and
            //    `ExplorerList` inside it) up too.
            //  • Layer 2 (floating search bar) deliberately does NOT
            //    ignore `.keyboard`, so SwiftUI's automatic avoidance
            //    lifts it above the keyboard while its `TextField`
            //    is first responder.
            ZStack(alignment: .bottom) {
                mapView
                    .overlay(alignment: .bottom) {
                        ExplorerDrawer(
                            detent: $sheetDetent,
                            topAccessory: {
                                // Floating actions toolbar — sits *just
                                // above* the drawer's grabber and rides
                                // up with the drawer because it shares
                                // the drawer's slide offset. Hidden at
                                // `.large` since the in-drawer header
                                // surfaces the same buttons.
                                HStack {
                                    Spacer()
                                    if sheetDetent != .large {
                                        FloatingDrawerActions(
                                            selectedDate: $selectedDate,
                                            showMenu: $showMenu,
                                            numFiltersActive: viewModel.numFiltersActive,
                                            showCalendar: viewModel.page == .events
                                        )
                                        .transition(
                                            .opacity.combined(
                                                with: .move(edge: .bottom)
                                            )
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            }
                        ) {
                            // Only show the search bar when the drawer is
                            // dragged all the way up; below that we let
                            // the collapsed header read as a toolbar.
                            ExplorerList(
                                searchText: $viewModel.searchText,
                                router: router,
                                showMenu: $showMenu,
                                selectedDate: $selectedDate,
                                isFullyExpanded: sheetDetent == .large
                            )
                                .environment(session)
                                .environment(manager)
                                .environment(viewModel)
                        }
                    }
                    // Pin this layer's frame against the keyboard.
                    // Applied to the composite (mapView + drawer overlay)
                    // so the overlay's bottom edge stays at the screen
                    // bottom even when the keyboard is up.
                    .ignoresSafeArea(.keyboard, edges: .bottom)

                // Floating search bar lives in a sibling ZStack layer
                // (not as another overlay on the map) so it can have
                // its own keyboard-avoidance behavior independently of
                // the drawer layer above. Toggled by the magnifying-
                // glass button in the parent `Events` toolbar.
                if viewModel.isSearchActive {
                    FloatingSearchBar(
                        text: $viewModel.searchText,
                        isActive: $viewModel.isSearchActive
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(
                        .move(edge: .bottom).combined(with: .opacity)
                    )
                }
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.86),
                value: sheetDetent
            )
            .animation(
                .spring(response: 0.35, dampingFraction: 0.86),
                value: viewModel.isSearchActive
            )
            // Pull the drawer all the way to the top whenever the user
            // opens search, so the floating bar filters against the full
            // list rather than a half-collapsed sliver. Only acts on
            // activation; dismissing search leaves the drawer wherever it
            // is (the `.large` position then persists via `@AppStorage`).
            .onChange(of: viewModel.isSearchActive) { _, isActive in
                guard isActive, sheetDetent != .large else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    sheetDetent = .large
                }
            }
        }
        }
        // Cluster-tap disambiguation sheet. Attached to the outer
        // `Group` so it works in both the compact and iPad layouts.
        // Tapping an event in the sheet dismisses it and pushes the
        // event detail onto the parent `NavigationStack` via the
        // shared router — same path the single-event pin uses.
        .sheet(item: $clusterSheet) { data in
            ClusterEventsSheet(events: data.events, router: router)
                .environment(session)
        }
    }
}

/// Floating calendar + filter buttons shown above the drawer when it
/// isn't fully extended. Both render as circular glass-effect chips
/// (iOS 26+) or `.regularMaterial`-filled circles on older systems.
/// Sharing `selectedDate` means picking from here or the in-drawer
/// calendar scrolls the list to the same group.
private struct FloatingDrawerActions: View {

    @Binding var selectedDate: Date
    @Binding var showMenu: Bool
    let numFiltersActive: Int
    let showCalendar: Bool
    /// Layout direction of the chip stack. `.horizontal` (default)
    /// matches the floating bar above the compact drawer; `.vertical`
    /// is used on iPad where the chips park beneath the `MapCompass`
    /// on the map's trailing edge.
    var axis: Axis = .horizontal

    @State private var showDatePicker = false
    @State private var todayDate = Date()

    var body: some View {
        let layout: AnyLayout = axis == .horizontal
            ? AnyLayout(HStackLayout(spacing: 8))
            : AnyLayout(VStackLayout(spacing: 8))

        layout {
            if showCalendar {
                CircularChip(systemImage: "calendar") {
                    showDatePicker = true
                }
                .popover(isPresented: $showDatePicker) {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: todayDate...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .frame(minWidth: 320)
                    .presentationCompactAdaptation(.popover)
                }
            }

            CircularChip(systemImage: "slider.vertical.3") {
                showMenu.toggle()
            }
        }
    }
}

/// Photos-style floating search bar that appears at the bottom of the
/// explorer when the user taps the magnifying-glass button in the
/// `Events` toolbar. Owns its own `@FocusState` so it can auto-focus
/// on appear — this is what summons the keyboard. Because the drawer
/// has opted out of `.keyboard` safe-area avoidance, this bar is the
/// one thing that actually rides above the keyboard.
private struct FloatingSearchBar: View {

    @Binding var text: String
    @Binding var isActive: Bool

    /// `@FocusState` lets us programmatically focus the field on appear
    /// and also force-resign focus when the user taps the cancel button.
    /// SwiftUI's automatic keyboard avoidance only kicks in for the
    /// currently-focused responder, so this is what makes the bar lift
    /// up over the keyboard.
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            searchPill
            cancelButton
        }
        .onAppear {
            // Small delay so the appearance transition finishes before
            // the keyboard animation starts — without this, the keyboard
            // sometimes summons before the bar has slid into place,
            // which looks janky.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isFocused = true
            }
        }
    }

    /// Capsule containing the magnifying glass + text field. `maxWidth:
    /// .infinity` is what lets it absorb the leftover horizontal space
    /// after the fixed-width cancel button takes its 44pt.
    @ViewBuilder
    private var searchPill: some View {
        let core = HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(
                String(localized: "search", table: "General"),
                text: $text
            )
            .focused($isFocused)
            .keyboardType(.webSearch)
            .submitLabel(.search)
            .textFieldStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)

        if #available(iOS 26.0, *) {
            core.glassEffect(.regular, in: .capsule)
        } else {
            core.background(.regularMaterial, in: Capsule())
        }
    }

    /// 44×44 circular glass button with a big plain `xmark`. Clears
    /// the query, resigns focus (which dismisses the keyboard via
    /// `@FocusState`), and toggles the bar back off.
    @ViewBuilder
    private var cancelButton: some View {
        let button = Button {
            text = ""
            isFocused = false
            isActive = false
        } label: {
            Image(systemName: "xmark")
                .imageScale(.large)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(Text("Cancel search"))

        if #available(iOS 26.0, *) {
            button.glassEffect(.regular.interactive(), in: .circle)
        } else {
            button.background(.regularMaterial, in: Circle())
        }
    }
}

/// Wrapper for the cluster-tap sheet binding. We can't bind a raw
/// `[Event]` to `.sheet(item:)` because `Array` isn't `Identifiable`,
/// so this gives the sheet a stable identity per tap (a fresh `UUID`
/// on each cluster-tap) and carries the event list as payload.
private struct ClusterEventsSheetData: Identifiable {
    let id = UUID()
    let events: [Event]
}

/// Sheet shown when a multi-event cluster pin is tapped. Mirrors the
/// day-grouped layout used by `ExplorerList` (pinned section headers
/// reading "Today", "Tomorrow", weekday names, …) so the user gets
/// the same scanning experience whether they're browsing the drawer
/// list or disambiguating a map cluster.
private struct ClusterEventsSheet: View {

    let events: [Event]
    let router: EventRouter

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        horizontalSizeClass == .regular
            ? [GridItem(.flexible(), spacing: 10),
               GridItem(.flexible(), spacing: 10)]
            : [GridItem(.flexible())]
    }

    private var cardScale: LIST_ITEM_SCALE {
        horizontalSizeClass == .regular ? .small : .regular
    }

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                ForEach(events.eventsGroupedByDay(), id: \.id) { group in
                    Section {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(group.events, id: \.id) { event in
                                EventListItem(
                                    event: event,
                                    scale: cardScale,
                                    onTap: {
                                        dismiss()
                                        router.navigate(to: .event(event: event))
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    } header: {
                        HStack {
                            Text(group.dayInString.capitalized)
                                .padding(.leading)
                                .padding(.vertical, 5)
                                .fontWeight(group.dayInString == "Today" ? .bold : .regular)

                            Spacer()
                        }
                        .background(Color.Background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        .allowsHitTesting(false)
                        .zIndex(1)
                    }.id(group.date)
                }
            }
            .padding(.top)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    EventsExplorer(router: .constant(EventRouter()), showMenu: .constant(false), showNewEvent: .constant(false))
        .environment(SessionStore())
        .environment(SearchManager())
        .environment(EventsViewModel())
}
