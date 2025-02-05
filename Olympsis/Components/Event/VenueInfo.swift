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
    @State private var locality: String = ""
    @State private var showSheet: Bool = false
    
    @EnvironmentObject private var event: Event
    
    /// Venue(s) name
    ///
    /// If we have one venue we show it's name.
    /// If we have 2+ venues we just show "Multiple Venues"
    private var name: String {
        if venues.count > 1 {
            return "Multiple Venues"
        } else {
            guard let venue = venues.first else {
                return "Venue"
            }
            return venue.name
        }
    }
    
    /// Venue(s) locality
    ///
    /// If we have one venue we just return that venue's locality.
    /// If we have 2+ venues the following applies:
    /// If they are in the same city then we return a locality with the city and state.
    /// If they are in the same state but not city we just return the state and country.
    /// If they are in the same country but not the same state then we just return the country.
//    private var locality: String {
//        return venues.locale()
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title3)
                .bold()
                .foregroundStyle(Color("foreground"))
                
            Text(locality)
                .foregroundStyle(Color("foreground"))
        }
        .padding(.leading)
        .onTapGesture {
            if venues.count > 1 {
                venuesTarget = 7
            } else {
                guard let venue = venues.first else {
                    return
                }
                if venue.description == "external" {
                    UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])")! as URL)
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
        .environmentObject(EVENTS[0])
        .environment(SessionStore())
}
