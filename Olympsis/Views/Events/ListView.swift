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
    @Binding var numFiltersActive: Int
    
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
    
    private var eventsGrouped: [DayGroup] {
        return events
            .eventsGroupedByDay()
    }
    
    private var fallbackLocation: CLLocation {
        guard let user = session.user, let hometown = user.hometown else {
            return CLLocation(latitude: 37.334886, longitude: -122.008988)
        }
        return CLLocation(latitude: hometown[0], longitude: hometown[1])
    }
    
    private var currentLocation: CLLocation {
        guard LocationManager.shared.isLocationAuthorized,
            let location = LocationManager.shared.location else {
            return fallbackLocation
        }
        
        return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    @MainActor
    private func fetchEvents() async {
        state = .loading
        
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
            if (session.events.contains(where: { $0.id != event.id })) {
                session.events.insert(event)
            }
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
        VStack {
            switch state {
            case .pending, .success:
                if events.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            SearchBar(text: $searchText)
                                .padding(.horizontal, 10)
                            
                            HStack(alignment: .bottom) {
                                Spacer()
                                DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                                    .frame(width: 120)
                                
                                FilterButton(numActive: $numFiltersActive, action: { showMenu.toggle() })
                            }
                            .padding(.top, 10)
                            .frame(height: 40)
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        .padding(.bottom, 50)
                        
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
                    }
                    .refreshable {
                        Task {
                            await fetchEvents()
                        }
                    }
                } else {
                    ScrollViewReader { proxy in
                        List {
                            VStack(spacing: 0) {
                                SearchBar(text: $searchText)
                                    .padding(.horizontal, 10)
                                
                                HStack(alignment: .bottom) {
                                    Spacer()
                                    DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                                        .frame(width: 120)
                                    
                                    FilterButton(numActive: $numFiltersActive, action: { showMenu.toggle() })
                                }
                                .frame(height: 40)
                                .padding(.horizontal)
                            }
                            
                            ForEach(eventsGrouped, id: \.id) { group in
                                Section(header: Text(group.dayInString.capitalized).fontWeight( group.dayInString == "Today" ? .bold : .regular)) {
                                    ForEach(group.events, id: \.id) { event in
                                        EventListItem(event: event)
                                            .scrollContentBackground(.hidden)
                                    }
                                }
                                .id(group.date)
                            }
                        }
                        .listStyle(.plain)
                        .onChange(of: selectedDate) { oldValue, newValue in
                            if let closestDate = findClosestDate(to: newValue, in: eventsGrouped) {
                                withAnimation {
                                    proxy.scrollTo(closestDate, anchor: .top)
                                }
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            guard state != .loading else { return }
                            await self.fetchEvents()
                        }
                    }
                }
            case .loading:
                ScrollView {
                    VStack(spacing: 0) {
                        SearchBar(text: $searchText)
                            .padding(.horizontal, 10)
                        
                        HStack(alignment: .bottom) {
                            Spacer()
                            DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                                .frame(width: 120)
                            
                            FilterButton(numActive: $numFiltersActive, action: { showMenu.toggle() })
                        }
                        .padding(.top, 10)
                        .frame(height: 40)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 50)
                    
                    ProgressView()
                }
            case .failure:
                ScrollView {
                    VStack(spacing: 0) {
                        SearchBar(text: $searchText)
                            .padding(.horizontal, 10)
                        
                        HStack(alignment: .bottom) {
                            Spacer()
                            DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                                .frame(width: 120)
                            
                            FilterButton(numActive: $numFiltersActive, action: { showMenu.toggle() })
                        }
                        .padding(.top, 10)
                        .frame(height: 40)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 50)
                    
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
                    
                    Spacer()
                }
                .refreshable {
                    Task {
                        await fetchEvents()
                    }
                }
            }
        }
    }
}

#Preview {
    ListView(state: .constant(.pending), searchText: .constant(""), showNewEvent: .constant(false), showMenu: .constant(false), numFiltersActive: .constant(0))
        .environment(SessionStore())
        .environment(SearchManager())
}
