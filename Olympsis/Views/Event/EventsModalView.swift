//
//  EventsModalView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

/// A view that shows the most recent and nearby events
struct EventsModalView: View {
    
    @Binding var showNewEvent: Bool
    @Binding var showMoreEvents: Bool
    @Environment(SessionStore.self) private var session
    
    private var events: [Event] {
        return session.events
    }
    private var eventsGrouped: [DayGroup] {
        return events.eventsGroupedByDay()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Nearby Events")
                    .font(.system(.headline))
                
                Spacer()

                Button(action:{ self.showMoreEvents.toggle() }){
                    HStack {
                        Text("More")
                            .bold()
                        Image(systemName: "chevron.down")
                    }.padding(.trailing)
                }.foregroundColor(.primary)
            }.padding()
            
            if (!events.isEmpty) {
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
                .padding(.top, -20)
            } else {
                VStack {
                    Text("No events found in your area. Change location settings or")
                        .italic()
                        .font(.callout)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        
                    Button(action: { self.showNewEvent.toggle() }) {
                        SimpleButtonLabel(text: "Create One")
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .presentationDragIndicator(.visible)
        .background(Color.Background.primary)
    }
}

#Preview {
    EventsModalView(showNewEvent: .constant(false), showMoreEvents: .constant(false))
        .environment(SessionStore())
}
