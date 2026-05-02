//
//  UpNext.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/12/26.
//

import SwiftUI

struct UpNextEvent: View {
    
    var events: [Event]
    var namespace: Namespace.ID? = nil

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Up Next")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                NavigationLink(value: EVENT_ROUTES.upNextEvents(events: events)) {
                    BasicButtonLabel(text: "View all", color: Color.Background.secondary)
                }
            }.padding(.horizontal, 10)

            if let event = events.first {
                NavigationLink(value: EVENT_ROUTES.event(event: event)) {
                    EventSmallListItem(event: event)
                }.modifier(ZoomTransitionSourceModifier(id: event.id, namespace: namespace))
            }
        }
    }
}

#Preview {
    NavigationStack {
        UpNextEvent(events: EVENTS)
    }
}
