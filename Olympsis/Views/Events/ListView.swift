//
//  ListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import MapKit
import SwiftUI

struct ListView: View {
    
    @State private var searchText = ""
    @State private var todayDate = Date()
    @State private var selectedDate = Date()
    
    @State private var pastEvents: Bool = false
    @State private var showNewEvent: Bool = false
    
    @State private var state: VIEW_STATE = .pending
    
    
    @Environment(SessionStore.self) private var session
    
    @AppStorage("searchRadius") private var radius: Double?
    
    private var events: [Event] {
        guard pastEvents else {
            return session.events
        }
        return session.pastEvents
    }
    
    private var eventsGrouped: [DayGroup] {
        
        var groups: [DayGroup] = [DayGroup]();
        events
            .filter {
                searchText.isEmpty ||
                $0.title.lowercased().contains(searchText.lowercased())
            }
            .forEach { e in

            let index = groups.firstIndex(where: {
                areDatesOnSameDay(
                    date1: Date(timeIntervalSince1970: TimeInterval($0.timestamp)),
                    date2: Date(timeIntervalSince1970: TimeInterval(e.startTime))
                )}
            )
            
            if index != nil {
                groups[index!].events.append(e)
                return
            } else {
                let newGroup = DayGroup(timestamp: e.startTime, events: [e])
                groups.append(newGroup)
                return
            }
        }
        
        var sorted = groups
            .sorted { (group1: DayGroup, group2: DayGroup) in
                if areDatesOnSameDay(date1: Date(timeIntervalSince1970: TimeInterval(group1.timestamp)), date2: Date(timeIntervalSince1970: TimeInterval(group2.timestamp))) {
                    // If dates are on the same day, prioritize item1
                    return true
                } else {
                    // If dates are not on the same day, sort by timestamp
                    return group1.timestamp < group2.timestamp
                }
            }
        for i in 0..<sorted.count {
            sorted[i].events = sorted[i].events.sorted { event1, event2 in
                return event1.startTime < event2.startTime
            }
        }
        
        return sorted
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
                status: pastEvents ? "completed" : "pending,live") else {
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
            status: pastEvents ? "completed" : "pending,live") else {
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
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    if pastEvents {
                        state = .pending
                        pastEvents = false
                    } else {
                        Task {
                            pastEvents = true
                            await fetchEvents()
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(pastEvents ? Color.gray : Color.Background.secondary)
                        HStack {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            Text("Past Events")
                        }
                    }
                }.frame(width: 140)
                
                DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                    .frame(width: 120)
            }
            .frame(height: 35)
            .padding(.horizontal)
            .padding(.top, 50)
            
            SearchBar(text: $searchText)
                .padding(.horizontal, 10)
            
            switch state {
            case .pending, .success:
                if events.isEmpty {
                    VStack {
                        Spacer()
                        
                        Text(pastEvents ? "No Past Events. Go Find some events or..." : "No Events found")
                        Button(action: { self.showNewEvent.toggle() }) {
                            SimpleButtonLabel(text: "Create One")
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(eventsGrouped, id: \.id) { group in
                                Section(header: Text(group.dayInString).fontWeight( group.dayInString == "Today" ? .bold : .regular)) {
                                    ForEach(group.events, id: \.id) { event in
                                        EventListItem(event: event)
                                            .listRowBackground(Color.clear)
                                    }
                                }.id(String(group.timestamp))
                            }
                        }
                        .listStyle(.plain)
                        .onChange(of: selectedDate) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo(Int(newValue.timeIntervalSince1970), anchor: .top)
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
        .background {
            Color.Background.primary
        }
        .fullScreenCover(isPresented: $showNewEvent, onDismiss: {
            Task {
                if pastEvents {
                    await self.fetchPastEvents()
                } else {
                    await self.fetchEvents()
                }
            }
        }) {
            NewEvent(manager: NewEventManager())
        }
    }
}

#Preview {
    ListView()
        .environment(SessionStore())
}
