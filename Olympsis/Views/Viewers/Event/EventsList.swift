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
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.dismiss) private var dismiss
    
    /// Struct for filtering events by the day they are to start
    struct DayGroup: Identifiable {
        let id = UUID()
        let day: Int
        var events: [Event]
        
        var dayInString: String {
            return events[0].timeToString()
        }
    }
    
    /// Groups the events by date
    var eventsGrouped: [DayGroup] {
        
        let calendar = Calendar.current
        var groups: [DayGroup] = [DayGroup]();
        
        events.forEach { e in
            guard let startTime = e.startTime else {
                return
            }
            
            let day = calendar.component(.day, from: Date(timeIntervalSince1970: TimeInterval(startTime)))
            let index = groups.firstIndex(where: { $0.day == day })
            
            if index != nil {
                groups[index!].events.append(e)
                return
            } else {
                let newGroup = DayGroup(day: day, events: [e])
                groups.append(newGroup)
                return
            }
        }
        
        return groups
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(eventsGrouped, id: \.day) { group in
                        Section(header: Text(group.dayInString)) {
                            ForEach(group.events, id: \.id) { event in
                                EventView(event: event)
                            }
                        }
                    }
                }.listStyle(.plain)
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
//  Tempoarily turned off need better UX
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date).datePickerStyle(.compact)
//                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EventsList_Previews: PreviewProvider {
    static var previews: some View {
        EventsList(events: EVENTS)
            .environmentObject(SessionStore())
    }
}
