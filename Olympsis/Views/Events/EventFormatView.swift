//
//  EventFormatView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/13/25.
//

import SwiftUI

struct EventFormatView: View {
    
    var event: Event
    
    private var formats: [CompetitionFormats] {
        guard let config = event.formatConfig,
              let values = config.formats else {
            return []
        }
        
        return values
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "event-formats-title", table: "Events"))
                .bold()
                .font(.title2)
            
            WrappingHStack(alignment: .leading) {
                ForEach(formats, id: \.self) { format in
                    CompetitionFormatView(format: format)
                }
            }
            
            HStack {
                Spacer()
            }
        }.padding(.horizontal)
    }
}

#Preview {
    EventFormatView(event: EVENTS[0])
}
