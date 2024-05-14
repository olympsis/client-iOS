//
//  EventFieldInfo.swift
//  Olympsis
//
//  Created by Joel on 12/11/23.
//

import SwiftUI

struct EventFieldInfo: View {
    
    @State var venue: Venue
    @State private var showSheet: Bool = false
    
    private var fieldLocality: String {
        guard venue.city != "" else {
            return ""
        }
        return venue.city + ", " + venue.state
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(venue.name)
                .font(.title3)
                .bold()
                .foregroundStyle(Color("foreground"))
                
            Text(fieldLocality)
                .foregroundStyle(Color("foreground"))
        }.padding(.leading)
            .onTapGesture {
                if venue.description == "external" {
                    UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])")! as URL)
                } else {
                    self.showSheet.toggle()
                }
            }
        .sheet(isPresented: $showSheet, content: {
            VenueView(venue: venue)
        })
    }
}

#Preview {
    EventFieldInfo(venue: FIELDS[0])
        .environmentObject(SessionStore())
}
