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
    
    var body: some View {
        ScrollView {
            ForEach(events) { event in
                NavigationLink(value: EVENT_ROUTES.event(event: event)) {
                    EventSmallListItem(event: event)
                        .padding(.horizontal, 10)
                        .environment(session)
                }
            }
        }
        .background(Color.Background.primary)
        .navigationTitle(Text("Upcoming Events"))
    }
}

#Preview {
    NavigationStack {
        UpNextEvents(events: EVENTS)
            .environment(SessionStore())
    }
}
