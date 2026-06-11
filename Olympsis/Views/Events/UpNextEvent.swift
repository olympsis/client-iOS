//
//  UpNext.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/12/26.
//

import SwiftUI

struct UpNextEvent: View {

    var events: [Event]
    var router: EventRouter? = nil
    var namespace: Namespace.ID? = nil
    @Environment(SessionStore.self) private var session
    
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
                Button {
                    router?.navigate(to: .event(event: event))
                } label: {
                    EventSmallListItem(event: event)
                        .padding(.horizontal)
                        .environment(session)
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .modifier(ZoomTransitionSourceModifier(id: event.id, namespace: namespace))
            }
        }
    }
}

#Preview {
    NavigationStack {
        UpNextEvent(events: EVENTS)
            .environment(SessionStore())
    }
}
