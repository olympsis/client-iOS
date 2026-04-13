//
//  ListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import MapKit
import SwiftUI

struct ListView: View {

    @Binding var state: VIEW_STATE
    @Binding var searchText: String
    @Binding var showNewEvent: Bool
    @Binding var showMenu: Bool
    let numFiltersActive: Int
    
    @Namespace private var heroNamespace
    @State private var todayDate = Date()
    @State private var selectedDate = Date()

    @Environment(SessionStore.self) private var session
    @Environment(SearchManager.self) private var manager
    @AppStorage("searchRadius") private var radius: Double?
    
    private var events: [Event] {
        guard !searchText.isEmpty else {
            return Array(session.events)
                // Check if any selected tag is in the event's tags
                .filter { event in
                    manager.selectedTags.isEmpty ||
                    manager.selectedTags.contains { tag in event.tags.contains(tag) }
                }
                // Check if any selected sport is in the event's sports
                .filter { event in
                    manager.selectedSports.isEmpty ||
                    manager.selectedSports.contains { sport in event.sports.contains(sport) }
                }
        }
        return Array(session.events)
            // Check if any selected tag is in the event's tags
            .filter { event in
                manager.selectedTags.isEmpty ||
                manager.selectedTags.contains { selectedTag in event.tags.contains(selectedTag) }
            }
            // Check if any selected sport is in the event's sports
            .filter { event in
                manager.selectedSports.isEmpty ||
                manager.selectedSports.contains { selectedSport in event.sports.contains(selectedSport) }
            }
            // Filter by search text in the title
            .filter { $0.title.localizedLowercase.contains(searchText.localizedLowercase) }
    }
    
    private var nextEvents: [Event] {
        guard let user = session.user,
              let userID = user.userID else {
            return []
        }
        return events.rsvpedEvents(userID: userID)
    }
    
    private var eventsGrouped: [DayGroup] {
        return events
            .eventsGroupedByDay()
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
            state = .loading
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
            state = .failure
            return
        }

        resp.forEach { event in
            session.events.insert(event)
        }

        state = .success
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
        ScrollViewReader { proxy in
            ScrollView {
                HStack(alignment: .bottom) {
                    Spacer()
                    DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                        .frame(width: 120)
                    
                    FilterButton(numActive: .constant(numFiltersActive), action: { showMenu.toggle() })
                }
                .zIndex(2)
                .frame(height: 40)
                .padding(.horizontal)
                
                switch state {
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
                                        EventListItem(event: event, namespace: heroNamespace)
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
            }
            .refreshable {
                guard state != .loading else { return }
                // Unstructured Task prevents cancellation from killing the network request,
                // while awaiting .value keeps the refresh spinner visible until completion.
                await Task { @MainActor in
                    await self.fetchEvents(isRefresh: true)
                }.value
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Event title")
        }
    }
}

#Preview {
    NavigationStack {
        ListView(state: .constant(.pending), searchText: .constant(""), showNewEvent: .constant(false), showMenu: .constant(false), numFiltersActive: 0)
            .environment(SessionStore())
            .environment(SearchManager())
    }
}
