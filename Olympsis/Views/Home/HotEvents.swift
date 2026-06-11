//
//  HotEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/29/24.
//

import SwiftUI

struct HotEvents: View {
    
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        if (session.hotEvents.count > 0) {
            HStack {
                VStack(alignment: .leading){
                    HStack {
                        Text(String(localized: "Hot Events", table: "General"))
                            .font(.system(.headline))
                        .padding()
                        Spacer()
                    }
                    
                    ForEach(session.hotEvents) { event in
                        EventListItem(event: event)
                            .environment(session)
                    }
                }
            }
        }
    }
}

#Preview {
    HotEvents()
        .environment(SessionStore())
}
