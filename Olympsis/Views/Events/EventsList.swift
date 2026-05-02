//
//  EventsList.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

/// A view that shows a list of events
struct EventsList: View {
    
    @State var events = [Event]()
    @State private var selectedDate = Date()
    @State private var state: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    /// Groups the events by date
    var eventsGrouped: [DayGroup] {
        
        var groups: [DayGroup] = [DayGroup]();
        events.forEach { e in

            let index = groups.firstIndex(where: {
                areDatesOnSameDay(
                    date1: $0.date,
                    date2: e.startTime
                )}
            )
            
            if let index {
                groups[index].events.append(e)
                return
            } else {
                let newGroup = DayGroup(date: e.startTime, events: [e])
                groups.append(newGroup)
                return
            }
        }
        return groups.sorted { (group1: DayGroup, group2: DayGroup) in
            if areDatesOnSameDay(date1: group1.date, date2: group2.date) {
                // If dates are on the same day, prioritize item1
                return true
            } else {
                // If dates are not on the same day, sort by timestamp
                return group1.date < group2.date
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(eventsGrouped, id: \.id) { group in
                        Section(header: Text(group.dayInString)) {
                            ForEach(group.events, id: \.id) { event in
                                EventListItem(event: event)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .id(group.date)
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }){
                        Image(systemName: "chevron.left")
                    }
                }
//  Tempoarily turned off need better UX
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
//                        .datePickerStyle(.compact)
//                }
            }
            .navigationTitle(String(localized: "events-title", table: "Events"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EventsList(events: EVENTS)
        .environment(SessionStore())
}
