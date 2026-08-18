//
//  NearbyVenues.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/29/24.
//

import SwiftUI

struct NearbyVenues: View {
    
    @State private var showMoreFields = false
    @Environment(SessionStore.self) private var session
    
    private var hasLocation: Bool {
        return LocationManager.shared.isAuthorized
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(String(localized: "nearby-venues", table: "General"))
                    .font(.system(.headline))
                
                Spacer()
                
                Button(action:{ self.showMoreFields.toggle() }){
                    Text(String(localized: "view-all", table: "General"))
                       .bold()
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(Color.primary)
            }
            .padding(.horizontal)
            
            Venues(venues: session.venues, status: session.state)
        }
        .padding(.top)
        .fullScreenCover(isPresented: $showMoreFields) {
            VenuesList(venues: session.venues)
        }
    }
}

#Preview {
    NearbyVenues()
        .environment(SessionStore())
}
