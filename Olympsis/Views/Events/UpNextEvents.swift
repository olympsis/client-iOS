//
//  UpNextEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/13/26.
//

import SwiftUI

struct UpNextEvents: View {
    
    var events: [Event]
    
    var body: some View {
        ScrollView {
            ForEach(events) { event in
                NavigationLink(value: EVENT_ROUTES.event(event: event)) {
                    EventSmallListItem(event: event)
                }
            }
        }.navigationTitle(Text("Upcoming Events"))
    }
}

#Preview {
    NavigationStack {
        UpNextEvents(events: EVENTS)
    }
}
