//
//  EventFieldInfo.swift
//  Olympsis
//
//  Created by Joel on 12/11/23.
//

import SwiftUI

struct VenueInfo: View {
    
    @Binding var venues: [Venue]
    @Binding var venuesTarget: Int
    @Binding var state: LOADING_STATE
    
    @State private var venue: Venue?
    @State private var locality: String = "Custom Coordinates"
    @State private var showSheet: Bool = false
    
    @Environment(Event.self) private var event: Event
    
    /// Venue(s) name
    ///
    /// If we have one venue we show it's name.
    /// If we have 2+ venues we just show "Multiple Venues"
    private var name: String {
        if venues.count > 1 {
            return "Multiple Locations"
        } else {
            guard let venue = venues.first else {
                return "Custom Location"
            }
            return venue.name
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "mappin.and.ellipse")
                .imageScale(.large)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.Foreground.default)
                    
                Text(locality)
                    .foregroundStyle(Color.Foreground.default)
            }
        }
        .onTapGesture {
            if venues.count > 1 {
                venuesTarget = 7
            } else {
                guard let venue = venues.first else {
                    return
                }
                if venue.description == "external" {
                    if let url = URL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])") {
                        UIApplication.shared.open(url)
                    }
                } else {
                    self.venue = venue
                }
            }
        }
        .redacted(reason: state == .success ? [] : .placeholder)
        .disabled(state != .success ? true : false)
        .onChange(of: venues, { oldValue, newValue in
            locality = venues.locale()
        })
        .sheet(item: $venue) { v in
            VenueView(venue: v)
        }
    }
}

#Preview {
    VenueInfo(venues: .constant([Venue]()), venuesTarget: .constant(0), state: .constant(.pending))
        .environment(EVENTS[0])
        .environment(SessionStore())
}
