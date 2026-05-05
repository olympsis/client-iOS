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
    var scale: Int = 1

    @State private var todayDate = Date()
    @State private var selectedDate = Date()

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
        var result = Array(session.events)
            .filter { event in
                manager.selectedTags.isEmpty ||
                manager.selectedTags.contains { tag in event.tags.contains(tag) }
            }
            .filter { event in
                manager.selectedSports.isEmpty ||
                manager.selectedSports.contains { sport in event.sports.contains(sport) }
            }
        if !searchText.isEmpty {
            let needle = searchText.localizedLowercase
            result = result.filter { $0.title.localizedLowercase.contains(needle) }
        }
        return result
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
            viewModel.state = .loading
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
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: currentLocation.coordinate.longitude,
            latitude: currentLocation.coordinate.latitude,
            radius: manager.radius,
            tags: tags,
            sports: sports) else {
            viewModel.state = .failure
            return
        }

        resp.forEach { event in
            session.events.insert(event)
        }

        viewModel.state = .success
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
        // @Bindable lets us derive Bindings from the @Observable view model.
        // It must live inside `body` (or be declared with @Bindable var) because
        // the view model itself comes from @Environment, not @State.
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

        // Picker lives in a sticky header *outside* the ScrollView.
        // Inside the scroll view it competed for gestures with the
        // sheet's `presentationContentInteraction(.scrolls)` and the
        // segmented control would intermittently swallow taps; pulling
        // it out also keeps it visible at the top of the sheet while
        // the user scrolls the list.
        return VStack(spacing: 0) {
            HStack {
                Spacer()
                Picker("Page", selection: $vm.page) {
                    ForEach(EVENT_EXPLORER_STATE.allCases, id: \.self) { page in
                        Text(page.localized).tag(page)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: SCREEN_WIDTH/3)
                Spacer()
            }
            .padding(.vertical)

            ScrollViewReader { proxy in
                ScrollView {
                    switch vm.page {
                case .events:
                    switch vm.state {
                    case .pending, .success:
                        if events.isEmpty {
                            VStack {
                                Image("illustrations/search")
                                    .resizable()
                                    .padding(.top)
                                    .frame(width: 150, height: 110)
                                
                                Text(String(localized: "no-events-title", table: "Events"))
                                    .font(.body)
                                    .padding(.top)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                                    .multilineTextAlignment(.center)
                                
                                Text(String(localized: "no-events-sub-title", table: "Events"))
                                    .font(.callout)
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }.padding(.top, 50)
                        } else {
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                
                                // MARK: - Up Next Events
                                if nextEvents.count > 0 && searchText.isEmpty {
                                    UpNextEvent(events: nextEvents, namespace: heroNamespace)
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
                            }.onChange(of: selectedDate) { oldValue, newValue in
                                if let closestDate = findClosestDate(to: newValue, in: eventsGrouped) {
                                    withAnimation {
                                        proxy.scrollTo(closestDate, anchor: .top)
                                    }
                                }
                            }
                        }
                    case .loading:
                        ProgressView()
                            .padding(.top, 50)
                    case .failure:
                        VStack {
                            Image("illustrations/error")
                                .resizable()
                                .frame(width: 170, height: 150)
                            Text(String(localized: "failed-events-title", table: "Events"))
                                .padding(.top)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            Text(String(localized: "failed-events-sub-title", table: "Events"))
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }.padding(.top, 50)
                    }
                case .venues:
                    switch vm.state {
                    case .pending, .success:
                        if (session.venues.isEmpty) {
                            VStack {
                                Image("illustrations/search")
                                    .resizable()
                                    .padding(.top)
                                    .frame(width: 150, height: 110)

                                Text(String(localized: "no-venues-title", table: "Events"))
                                    .font(.body)
                                    .padding(.top)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                                    .multilineTextAlignment(.center)

                                Text(String(localized: "no-venues-sub-title", table: "Events"))
                                    .font(.callout)
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }.padding(.top, 50)
                        } else {
                            // `LazyVStack` so a long venues list only
                            // realizes the cards currently on screen,
                            // matching the events branch and avoiding
                            // a wave of `KFImage` decodes on first show.
                            LazyVStack {
                                ForEach(session.venues) { venue in
                                    VenueListItem(
                                        venue: venue,
                                        scale: listItemScale,
                                        onTap: router.map { router in
                                            { router.navigate(to: .venue(venue: venue)) }
                                        }
                                    )
                                }
                            }
                        }
                    case .loading:
                        ProgressView()
                            .padding(.top, 50)
                    case .failure:
                        VStack {
                            Image("illustrations/error")
                                .resizable()
                                .frame(width: 170, height: 150)
                            Text(String(localized: "failed-venues-title", table: "Events"))
                                .padding(.top)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)

                            Text(String(localized: "failed-venues-sub-title", table: "Events"))
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }.padding(.top, 50)
                    }
                    }
                }
            }
        }
    }
}

#Preview {
    ExplorerList(searchText: .constant(""))
        .environment(SessionStore())
        .environment(SearchManager())
        .environment(EventsViewModel())
}
