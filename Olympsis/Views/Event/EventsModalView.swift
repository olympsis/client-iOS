//
//  EventsModalView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

/// A view that shows the most recent and nearby events
struct EventsModalView: View {
    
    @Binding var events: [Event]
    @State private var showMore = false
    @EnvironmentObject private var session: SessionStore
    
    /// Struct for filtering events by the day they are to start
    struct DayGroup: Identifiable {
        let id = UUID()
        let timestamp: Int
        var events: [Event]
        
        var dayInString: String {
            return events[0].timeToString()
        }
    }
    
    /// Groups the events by date
    var eventsGrouped: [DayGroup] {
        
        var groups: [DayGroup] = [DayGroup]();
        events.forEach { e in
            guard let startTime = e.startTime else {
                return
            }
            
            let index = groups.firstIndex(where: {
                areDatesOnSameDay(
                    date1: Date(timeIntervalSince1970: TimeInterval($0.timestamp)),
                    date2: Date(timeIntervalSince1970: TimeInterval(startTime))
                )}
            )
            
            if index != nil {
                groups[index!].events.append(e)
                return
            } else {
                let newGroup = DayGroup(timestamp: startTime, events: [e])
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
                return event1.startTime ?? 0 < event2.startTime ?? 0
            }
        }
        
        return sorted
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Nearby Events")
                    .font(.system(.headline))
                
                Spacer()

                Button(action:{ self.showMore.toggle() }){
                    HStack {
                        Text("More")
                            .bold()
                        Image(systemName: "chevron.down")
                    }.padding(.trailing)
                }.foregroundColor(.primary)
            }.padding()
            
            List {
                ForEach(eventsGrouped, id: \.id) { group in
                    Section(header: Text(group.dayInString).fontWeight( group.dayInString == "Today" ? .bold : .regular)) {
                        ForEach(group.events, id: \.id) { event in
                            EventListItem(event: event)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .padding(.top, -20)
            .fullScreenCover(isPresented: $showMore) {
                EventsList(events: session.events)
            }
        }
        .presentationDragIndicator(.visible)
        .background(Color("background-color/primary"))
    }
}

#Preview {
    let session = SessionStore()
    session.events = EVENTS
    return EventsModalView(events: .constant(EVENTS))
        .environmentObject(session)
}
