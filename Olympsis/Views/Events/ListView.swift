//
//  ListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import MapKit
import SwiftUI

struct ListView: View {
    
    @Binding var showNewEvent: Bool
    
    @State private var searchText = ""
    @State private var todayDate = Date()
    @State private var selectedDate = Date()
    
    @State private var state: VIEW_STATE = .pending
    
    @Environment(SessionStore.self) private var session
    
    @AppStorage("searchRadius") private var radius: Double?
    
    private var events: [Event] {
        return session.events
    }
    
    private var eventsGrouped: [DayGroup] {
        return events
            .filter { searchText.isEmpty ? true : $0.title.lowercased().contains(searchText.lowercased()) }
            .eventsGroupedByDay()
    }
    
    private var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), latitudinalMeters: 4000, longitudinalMeters: 4000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), latitudinalMeters: 4000, longitudinalMeters: 4000)
    }
    
    @MainActor
    private func fetchEvents() async {
        state = .loading
        
        guard let user = session.user,
              let sports = user.sports else {
            state = .failure
            return
        }
        
        // If user has location on
        if let location = session.locationManager.location {
            guard let resp = await session.eventObserver.fetchEvents(
                longitude: location.longitude,
                latitude: location.latitude,
                radius: Int(radius ?? 8050),
                sports: sports.joined(separator: ","),
                status: "pending,live") else {
                state = .failure
                return
            }
            session.pastEvents = resp
            state = .success
            return
        }
        
        // Use fallback location
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: fallbackLocation.center.longitude,
            latitude: fallbackLocation.center.latitude,
            radius: Int(radius ?? 8050),
            sports: sports.joined(separator: ","),
            status: "pending,live") else {
            state = .failure
            return
        }
        session.pastEvents = resp
        state = .success
    }
    
    @MainActor
    private func fetchPastEvents() async {
        state = .loading
        
        guard let user = session.user,
              let sports = user.sports else {
            state = .failure
            return
        }
        
        // If user has location on
        if let location = session.locationManager.location {
            guard let resp = await session.eventObserver.fetchEvents(
                longitude: location.longitude,
                latitude: location.latitude,
                radius: Int(radius ?? 8050),
                sports: sports.joined(separator: ","),
                status: "completed") else {
                state = .failure
                return
            }
            session.pastEvents = resp
            state = .success
            return
        }
        
        // Use fallback location
        guard let resp = await session.eventObserver.fetchEvents(
            longitude: fallbackLocation.center.longitude,
            latitude: fallbackLocation.center.latitude,
            radius: Int(radius ?? 8050),
            sports: sports.joined(separator: ","),
            status: "completed") else {
            state = .failure
            return
        }
        session.pastEvents = resp
        state = .success
    }
    
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
                    VStack {
                        Spacer()
                        
                        Text("No Events found")
                        Button(action: { self.showNewEvent.toggle() }) {
                            SimpleButtonLabel(text: "Create One")
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollViewReader { proxy in
                        List {
                            HStack {
                                Spacer()
                                DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                                    .frame(width: 120)
                            }
                            .frame(height: 40)
                            .padding(.horizontal)
                            .listRowBackground(Color.Background.primary)
                            
                            SearchBar(text: $searchText)
                                .padding(.horizontal, 10)
                                .listRowBackground(Color.Background.primary)
                            
                            ForEach(eventsGrouped, id: \.id) { group in
                                Section(header: Text(group.dayInString).fontWeight( group.dayInString == "Today" ? .bold : .regular)) {
                                    ForEach(group.events, id: \.id) { event in
                                        EventListItem(event: event)
                                            .scrollContentBackground(.hidden)
                                    }
                                }
                                .id(group.date)
                                .listRowBackground(Color.Background.primary)
                            }
                        }
                        .listStyle(.plain)
                        .listRowBackground(Color.Background.primary)
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
                            await self.fetchEvents()
                        }
                    }
                }
            case .loading:
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            case .failure:
                VStack {
                    Spacer()
                    Image("illustrations/404")
                        .resizable()
                        .frame(width: SCREEN_WIDTH/1.3, height: SCREEN_WIDTH/1.3)
                    Text("Failed to load events")
                        .font(.title3)
                    Spacer()
                }
            }
        }
        .background { Color.Background.primary }
    }
}

#Preview {
    ListView(showNewEvent: .constant(false))
        .environment(SessionStore())
}
