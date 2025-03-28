//
//  EventLocation.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct EventLocation: View {
    
    @Binding var venues: [Venue]
    @EnvironmentObject private var event: Event
    
    private var venueDescriptors: [VenueDescriptor] {
        return event.venues
    }
    
    var body: some View {
        if !venues.isEmpty {
            Group {
                HStack {
                    Text("Locations(s)")
                        .font(.title2)
                        .bold()
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center) {
                    ForEach(venueDescriptors, id: \.self) {
                        VenueDescriptorView(item: $0)
                    }
                }
            }
            .id(7)
            .padding(.horizontal)
        }
    }
}

#Preview {
    EventLocation(venues: .constant([]))
        .environmentObject(EVENTS[0])
}
