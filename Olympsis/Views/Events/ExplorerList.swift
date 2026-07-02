//
//  ExplorerList.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/2/26.
//

import SwiftUI
import CoreLocation

struct ExplorerList: View {
    
    @Binding var searchText: String
    /// Optional router so list items can push onto the shared
    /// `NavigationStack` even when the list is hosted inside a sheet
    /// (where `NavigationLink` can't see the parent stack).
    var router: EventRouter? = nil
    /// Bound to the parent's filter-sheet state. Pass through from
    /// `EventsExplorer` so the in-drawer filter button toggles the
    /// existing `FilterView` sheet that lives on `Events`.
    var showMenu: Binding<Bool>? = nil
    /// Bound to the parent's new-event sheet state. The new-event flow
    /// is presented as a sheet by the host (`Events`), not a nav route,
    /// so the empty-state "create" CTA flips this instead of routing.
    var showNewEvent: Binding<Bool>? = nil
    /// Lifted to the parent so the floating drawer-actions overlay
    /// and the in-drawer calendar share the same picked date — both
    /// pickers should scroll the list to the same place.
    var selectedDate: Binding<Date>? = nil
    /// `true` when the host drawer is fully expanded (or when there's
    /// no drawer at all, e.g. the iPad split layout). When `false` we
    /// hide the search bar and only show the action buttons in the
    /// header so the collapsed drawer reads as a compact toolbar.
    var isFullyExpanded: Bool = true
    var scale: Int = 1

    @State private var todayDate = Date()
    /// Local fallback when no `selectedDate` binding is provided
    /// (preview / standalone use).
    @State private var localSelectedDate = Date()

    /// One source of truth for the date — caller's binding when given,
    /// the local fallback otherwise. Used by both the popover picker
    /// and the `.onChange` scroll-to handler below.
    private var dateBinding: Binding<Date> {
        selectedDate ?? $localSelectedDate
    }
    /// Drives the calendar popover that lets the user jump the list
    /// to a specific date.
    @State private var showDatePicker = false

    /// Map the numeric scale that callers (e.g. the iPad split layout)
    /// pass us into the `EventListItem`-flavored enum. Anything above the
    /// default of 1 is treated as "compress" mode — today there are only
    /// two visual variants, so we collapse the spectrum into them here.
    private var listItemScale: LIST_ITEM_SCALE {
        scale > 1 ? .small : .regular
    }
    
    @Environment(SessionStore.self) private var session
    @Environment(SearchManager.self) private var manager
    @Environment(EventsViewModel.self) private var viewModel
    
    @Namespace private var heroNamespace
    
    /// Filtered events for the current tags / sports / search query.
    /// Body computes this once into a local `let` and passes it to every
    /// downstream consumer (`isEmpty` check, group banner, ForEach,
    /// nextEvents) — avoids re-running `Array(session.events)` and three
    /// `.filter`s on every property access during a render pass.
    private func computeEvents() -> [Event] {
        // Shared with the map annotations via `filteredForExplorer` so the
        // list and the map always agree on what the filters include.
        Array(session.events).filteredForExplorer(
            tags: manager.selectedTags,
            sports: manager.selectedSports,
            search: searchText
        )
    }

    /// Filtered venues for the current sports filter / search query.
    /// Mirrors `computeEvents()` so the venues page honors the same
    /// selections instead of always rendering the full `session.venues`
    /// cache.
    private func computeVenues() -> [Venue] {
        session.venues.filteredForExplorer(
            sports: manager.selectedSports,
            search: searchText
        )
    }
    
    private var fallbackLocation: CLLocation {
        guard let user = session.user, let hometown = user.hometown else {
            return CLLocation(latitude: 37.334886, longitude: -122.008988)
        }
        return CLLocation(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0])
    }
    
    private var currentLocation: CLLocation {
        guard LocationManager.shared.isLocationAuthorized,
            let location = LocationManager.shared.location else {
            return fallbackLocation
        }
        
        return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    /// Shared fetch logic. When `isRefresh` is true, skips the .loading state
    /// change to avoid a view rebuild that causes ScrollView to get stuck.
    @MainActor
    private func fetchEvents(isRefresh: Bool = false) async {
        if !isRefresh {
            viewModel.eventsState = .loading
        }

        var tags: String? = nil
        var sports: String? = nil

        if (!manager.tags.isEmpty) {
            tags = manager.getTagsString()
        }

        if (!manager.sports.isEmpty) {
            sports = manager.getSportsString()
        }

        // Use fallback location
        // The server expects the radius in meters; `manager.radius` is in
        // miles, so convert before sending — matching the venues fetch.
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: currentLocation.coordinate.longitude,
            latitude: currentLocation.coordinate.latitude,
            radius: milesToMeters(radius: manager.radius),
            tags: tags,
            sports: sports) else {
            viewModel.eventsState = .failure
            return
        }

        resp.forEach { event in
            session.events.insert(event)
        }

        viewModel.eventsState = .success
    }
    
    @MainActor
    private func findClosestDate(to targetDate: Date, in groups: [DayGroup]) -> Date? {
        let calendar = Calendar.current
        
        // Convert the target date to the start of day
        let startOfTargetDate = calendar.startOfDay(for: targetDate)
        
        // Find groups whose dates are within one day of the selected date
        let groupsWithinOneDay = groups.filter { group in
            let startOfGroupDate = calendar.startOfDay(for: group.date)
            let components = calendar.dateComponents([.day], from: startOfGroupDate, to: startOfTargetDate)
            return abs(components.day ?? Int.max) <= 1
        }
        
        // If we found groups within a day, pick the closest
        if !groupsWithinOneDay.isEmpty {
            return groupsWithinOneDay.min { group1, group2 in
                let startOfDate1 = calendar.startOfDay(for: group1.date)
                let startOfDate2 = calendar.startOfDay(for: group2.date)
                
                let diff1 = abs(calendar.dateComponents([.day], from: startOfDate1, to: startOfTargetDate).day ?? Int.max)
                let diff2 = abs(calendar.dateComponents([.day], from: startOfDate2, to: startOfTargetDate).day ?? Int.max)
                
                return diff1 < diff2
            }?.date
        }
        
        // If no group is within a day, find the absolute closest
        return groups.min { group1, group2 in
            let startOfDate1 = calendar.startOfDay(for: group1.date)
            let startOfDate2 = calendar.startOfDay(for: group2.date)
            
            let diff1 = abs(calendar.dateComponents([.day], from: startOfDate1, to: startOfTargetDate).day ?? Int.max)
            let diff2 = abs(calendar.dateComponents([.day], from: startOfDate2, to: startOfTargetDate).day ?? Int.max)
            
            return diff1 < diff2
        }?.date
    }
    
    var body: some View {

        @Bindable var vm = viewModel

        // Single per-render snapshot used by every consumer below.
        // Previously each computed property re-allocated the array and
        // re-ran every filter on every access (`isEmpty`, `nextEvents`,
        // `eventsGrouped`, ForEach, onChange handler).
        let events = computeEvents()
        let nextEvents: [Event] = {
            guard let userID = session.user?.userID else { return [] }
            return events.rsvpedEvents(userID: userID)
        }()
        let eventsGrouped = events.eventsGroupedByDay()

        // Same per-render snapshot for venues so the search field and
        // sports filter actually narrow the venues list (previously it
        // rendered the unfiltered `session.venues` cache).
        let venues = computeVenues()

        return VStack(spacing: 8) {

            // MARK: - Picker + actions row
            //
            // Picker on the leading edge, calendar + filter buttons on
            // the trailing edge, with a `Spacer` in between so the
            // buttons hug the right and the picker hugs the left.
            // Floating search bar in `EventsExplorer` replaces the
            // old in-drawer search field, so this row no longer has a
            // text input — just the segmented control and the two
            // action buttons. Buttons are gated on `isFullyExpanded`
            // so the collapsed drawer header doesn't double up with
            // the `FloatingDrawerActions` chips outside the drawer.
            HStack(spacing: 8) {
                // Custom segmented control rather than the system
                // `Picker(.segmented)`. The native picker is a bridged
                // `UISegmentedControl`; hosted inside the explorer's
                // overlay drawer it swallowed its *first* tap after the
                // drawer appeared (the tap only resolved the responder
                // chain), which is why switching pages used to need a
                // double tap. Building the control out of plain SwiftUI
                // buttons sidesteps the UIKit bridge, so the first tap
                // registers immediately.
                ExplorerPagePicker(selection: $vm.page)
                    .padding(.horizontal)
                    // Lock the events/venues toggle while a fetch is in
                    // flight so the user can't flip pages mid-load (which
                    // would show one page's skeletons against the other
                    // page's data). `.disabled` also dims it as a cue.
                    .disabled(vm.state == .loading)

                if isFullyExpanded {
                    Spacer()

                    if vm.page == .events {
                        Group {
                            if #available(iOS 26.0, *) {
                                Button {
                                    showDatePicker = true
                                } label: {
                                    Image(systemName: "calendar")
                                        .imageScale(.medium)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                        .frame(width: 38, height: 38)
                                }
                                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
                            } else {
                                Button {
                                    showDatePicker = true
                                } label: {
                                    Image(systemName: "calendar")
                                        .imageScale(.medium)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                        .frame(width: 38, height: 38)
                                }
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .popover(isPresented: $showDatePicker) {
                            DatePicker(
                                "",
                                selection: dateBinding,
                                in: todayDate...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            // Without an explicit min width the popover
                            // container squishes to the source button's
                            // width on compact size classes and the
                            // day-grid columns end up overlapping.
                            .frame(minWidth: 320)
                            .presentationCompactAdaptation(.popover)
                        }
                    }

                    if let showMenu = showMenu {
                        FilterButton(
                            numActive: .constant(vm.numFiltersActive),
                            action: { showMenu.wrappedValue.toggle() }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .animation(.spring(response: 0.3, dampingFraction: 0.86), value: isFullyExpanded)

            ScrollViewReader { proxy in
                ScrollView {
                    switch vm.page {
                case .events:
                    switch vm.eventsState {
                    case .pending, .success:
                        if events.isEmpty {
                            // No events nearby (including a 204 response) —
                            // show the encouraging empty state instead of the
                            // failure view. The "create" CTA only appears when
                            // we have a `showNewEvent` binding to present the
                            // new-event sheet with.
                            EventsEmptyState(
                                onCreate: showNewEvent.map { showNewEvent in
                                    { showNewEvent.wrappedValue = true }
                                }
                            )
                        } else {
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                
                                // MARK: - Up Next Events
                                if nextEvents.count > 0 && searchText.isEmpty {
                                    UpNextEvent(
                                        events: nextEvents,
                                        router: router,
                                        namespace: heroNamespace
                                    )
                                        .padding(.vertical, 10)
                                }
                                
                                // MARK: - Events List
                                ForEach(eventsGrouped, id: \.id) { group in
                                    Section {
                                        ForEach(group.events, id: \.id) { event in
                                            EventListItem(
                                                event: event,
                                                scale: listItemScale,
                                                namespace: heroNamespace,
                                                onTap: router.map { router in
                                                    { router.navigate(to: .event(event: event)) }
                                                }
                                            )
                                                .padding(.horizontal)
                                        }
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
                            }.onChange(of: dateBinding.wrappedValue) { oldValue, newValue in
                                if let closestDate = findClosestDate(to: newValue, in: eventsGrouped) {
                                    withAnimation {
                                        proxy.scrollTo(closestDate, anchor: .top)
                                    }
                                }
                            }
                        }
                    case .loading:
                        // Skeleton placeholders instead of a bare spinner —
                        // gives the list the same shape it'll have once the
                        // events land, so the transition doesn't jump.
                        LazyVStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                EventListItemTemplate(scale: listItemScale)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    case .failure:
                        // Generic network/error state. Retry re-fetches
                        // whatever currently failed — both resources if both
                        // failed, or just this one if it's the only failure.
                        ExplorerErrorState {
                            Task { await vm.retry(session) }
                        }
                    }
                case .venues:
                    switch vm.venuesState {
                    case .pending, .success:
                        if (venues.isEmpty) {
                            // No venues match the current search / sports
                            // filter (or none nearby, including a 204
                            // response) — encourage the user to email us so
                            // we can add venues in their area. Button opens
                            // the Mail app.
                            VenuesEmptyState()
                        } else {
                            // Neighborhood-grouped index (chips + per-hood
                            // sections). The shared component handles the
                            // LazyVStack laziness and caches the grouping, so
                            // this matches the Home "view all" sheet exactly.
                            // Tapping a venue routes onto the shared nav stack.
                            VenueNeighborhoodIndex(
                                venues: venues,
                                scale: listItemScale,
                                onSelect: router.map { router in
                                    { venue in router.navigate(to: .venue(venue: venue)) }
                                }
                            )
                        }
                    case .loading:
                        // Same skeleton treatment as the events page so
                        // switching tabs (or landing here first) stays
                        // visually consistent while venues load.
                        LazyVStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                // `VenueListItemTemplate` manages its own
                                // width, so no extra horizontal padding here.
                                VenueListItemTemplate()
                            }
                        }
                        .padding(.top, 10)
                    case .failure:
                        // Same generic error state as the events page; the
                        // retry coordinates across both resources.
                        ExplorerErrorState {
                            Task { await vm.retry(session) }
                        }
                    }
                    }
                    
                    // Bottom padding to make sure we can scroll all the way up
                    Spacer(minLength: 150)
                }
                // Floating scroll-to-top button — only on the venues page so
                // users can jump back up to pick another neighborhood.
                .scrollToTopButton(isEnabled: vm.page == .venues)
            }
        }
    }
}

/// Two-segment control that drives the events/venues page selection.
///
/// Replaces `Picker(.segmented)` to avoid the bridged `UISegmentedControl`
/// first-tap issue inside the overlay drawer (see call site). Pure SwiftUI
/// buttons with a `matchedGeometryEffect` thumb that slides between the
/// selected segment, styled to read like a system segmented control.
private struct ExplorerPagePicker: View {

    @Binding var selection: EVENT_EXPLORER_STATE

    /// Drives the sliding-thumb animation between segments.
    @Namespace private var thumb

    var body: some View {
        HStack(spacing: 0) {
            ForEach(EVENT_EXPLORER_STATE.allCases, id: \.self) { page in
                segment(for: page)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(uiColor: .tertiarySystemFill))
        )
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private func segment(for page: EVENT_EXPLORER_STATE) -> some View {
        let isSelected = selection == page
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selection = page
            }
        } label: {
            Text(page.localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background {
                    // Only the selected segment paints the thumb; the
                    // shared `matchedGeometryEffect` id makes it slide
                    // across when the selection changes.
                    if isSelected {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.Background.primary)
                            .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
                            .matchedGeometryEffect(id: "thumb", in: thumb)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExplorerList(searchText: .constant(""))
        .environment(SessionStore())
        .environment(SearchManager())
        .environment(EventsViewModel())
}
