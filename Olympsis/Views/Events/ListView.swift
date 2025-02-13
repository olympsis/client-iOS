//
//  ListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import SwiftUI

struct ListView: View {
    
    @State private var searchText = ""
    @State private var todayDate = Date()
    @State private var selectedDate = Date()
    
    @Environment(SessionStore.self) private var session
    
    private var eventsGrouped: [DayGroup] {
        
        var groups: [DayGroup] = [DayGroup]();
        session.events.forEach { e in

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
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.quinary)
                        HStack {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            Text("Past Events")
                        }
                    }
                }.frame(width: 140)
                
                DatePicker("",selection: $selectedDate, in: todayDate..., displayedComponents: [.date])
                    .frame(width: 120)
            }
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.top, 50)
            
            SearchBar(text: $searchText)
                .padding(.horizontal, 10)
            
            List {
                ForEach(eventsGrouped, id: \.id) { group in
                    Section(header: Text(group.dayInString).fontWeight( group.dayInString == "Today" ? .bold : .regular)) {
                        ForEach(group.events, id: \.id) { event in
                            EventListItem(event: event)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .background {
            Color.Background.primary
        }
    }
}

#Preview {
    ListView()
        .environment(SessionStore())
}
