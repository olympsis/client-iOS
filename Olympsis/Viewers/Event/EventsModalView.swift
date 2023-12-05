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
        VStack {
            HStack {
                Text("Nearby Events")
                    .font(.system(.headline))
                
                Spacer()
//  Turned off tempoarily for better UX
//                Button(action:{ self.showMore.toggle() }){
//                    HStack {
//                        Text("More")
//                            .bold()
//                        Image(systemName: "chevron.down")
//                    }.padding(.trailing)
//                }.foregroundColor(.primary)
            }.padding()
            List {
                ForEach(eventsGrouped, id: \.day) { group in
                    Section(header: Text(group.dayInString)) {
                        ForEach(group.events, id: \.id) { event in
                            EventView(event: event)
                        }
                    }
                }
            }.listStyle(.plain)
                .padding(.top, -20)
            .fullScreenCover(isPresented: $showMore) {
                EventsList(events: session.events)
            }
        }
    }
}

struct EventsModalView_Previews: PreviewProvider {
    static var previews: some View {
        EventsModalView(events: .constant(EVENTS)).environmentObject(SessionStore())
    }
}
