//
//  NearbyVenues.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/29/24.
//

import SwiftUI

struct NearbyVenues: View {
    
    @State private var showMoreFields = false
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(String(localized: "Nearby Venues", table: "General"))
                    .font(.system(.headline))
                
                Spacer()
                
                Button(action:{ self.showMoreFields.toggle() }){
                    Text(String(localized: "View All", table: "General"))
                       .bold()
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(Color.primary)
            }
            .padding(.horizontal)
            
            Venues(venues: $session.venues, status: $session.state)
        }
        .fullScreenCover(isPresented: $showMoreFields) {
            VenuesList(venues: session.venues)
        }
    }
}

#Preview {
    NearbyVenues()
        .environmentObject(SessionStore())
}
