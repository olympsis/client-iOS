//
//  UpNext.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/12/26.
//

import SwiftUI

struct UpNextEvents: View {
    
    var events: [Event]
    var namespace: Namespace.ID? = nil
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Up Next")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    BasicButtonLabel(text: "View all", color: Color.Background.secondary)
                }
            }.padding(.horizontal, 10)
            
            if let event = events.first {
                NavigationLink(destination: EventView(event: event, namespace: namespace).environment(event).environment(session)) {
                    EventSmallListItem(event: event)
                }.modifier(ZoomTransitionSourceModifier(id: event.id, namespace: namespace))
            }
        }
    }
}

#Preview {
    UpNextEvents(events: EVENTS)
        .environment(SessionStore())
}
