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
                        .padding(.horizontal, 10)
                }
            } else {
                HStack {
                    Spacer()
                    VStack {
                        Text(String(localized: "no-past-events", table: "Profile"))
                            .padding(.top)
                        Text(String(localized: "go-find-some", table: "Profile"))
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
