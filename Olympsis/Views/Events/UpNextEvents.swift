//
//  UpNextEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/13/26.
//

import SwiftUI

struct UpNextEvents: View {
    
    var events: [Event]
    @Environment(SessionStore.self) private var session
    
    /// Events split into the Today / This Week / Next Week (+ Later) buckets.
    /// Empty sections are already dropped by `eventsGroupedForUpNext`.
    private var sections: [UpNextSectionGroup] {
        events.eventsGroupedForUpNext()
    }
    
    var body: some View {
        ScrollView {
            // Lazy + pinned headers matches the events list on the explorer,
            // so the section title stays visible while scrolling through it.
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                ForEach(sections) { group in
                    Section {
                        ForEach(group.events) { event in
                            NavigationLink(value: EVENT_ROUTES.event(event: event)) {
                                EventSmallListItem(event: event)
                                    .padding(.horizontal, 10)
                                    .environment(session)
                            }
                        }
                    } header: {
                        HStack {
                            Text(group.section.title)
                                .padding(.leading)
                                .padding(.vertical, 5)
                                .fontWeight(group.section == .today ? .bold : .regular)
                            
                            Spacer()
                        }
                        .background(Color.Background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 10)
                        .allowsHitTesting(false)
                        .zIndex(1)
                    }
                }
            }
        }
        .background(Color.Background.primary)
        .navigationTitle(Text(String(localized: "upcoming-events", table: "Events")))
    }
}

#Preview {
    NavigationStack {
        UpNextEvents(events: EVENTS)
            .environment(SessionStore())
    }
}
