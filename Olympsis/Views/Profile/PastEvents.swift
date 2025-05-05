//
//  PastEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct PastEvents: View {
    
    private var pastEvents: [Event] {
        return Array(session.pastEvents.sorted { $0.startTime > $1.startTime })
    }
    
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        VStack {
            if !pastEvents.isEmpty {
                ForEach(pastEvents, id: \.id) { event in
                    EventListItem(event: event)
                }
            } else {
                HStack {
                    Spacer()
                    VStack {
                        Text("No Past Events Found")
                            .padding(.top)
                        Text("Go find some!")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                    }.padding(.top, 50)
                    Spacer()
                }
            }
        }.padding(.bottom)
    }
}

#Preview {
    PastEvents()
        .environment(SessionStore())
}
