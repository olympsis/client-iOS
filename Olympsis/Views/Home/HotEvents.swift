//
//  HotEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/29/24.
//

import SwiftUI

struct HotEvents: View {
    
    @EnvironmentObject private var session: SessionStore
    
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
                        EventSmallListItem(event: event)
                    }
                }
            }
        }
    }
}

#Preview {
    HotEvents()
        .environmentObject(SessionStore())
}
