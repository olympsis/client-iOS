//
//  Home.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import os
import SwiftUI
import CoreLocation
import NotificationCenter

struct Home: View {
    
    @State private var showDetail = false
    @State private var showMoreFields = false
    
    @EnvironmentObject private var session: SessionStore
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "home_view")
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                
                //MARK: - Welcome message
                WelcomeCard()
                    .padding(.top, 25)
                    .environmentObject(session)
                
                // MARK: - Announcements
                AnnouncementsView()
                    .environmentObject(session)
                
                // MARK: - Next Events
                NextEvents()
                    .environmentObject(session)
                
                // MARK: - Hot Events
                HotEvents()
                    .environmentObject(session)
                
                // MARK: - Nearby Venues
                NearbyVenues()
                    .environmentObject(session)
                
                Spacer(minLength: 100)
                
            }
            .onReceive(session.locationManager.$location) { newLoc in
                
                // make sure new location is valid
                guard newLoc != nil else {
                    return
                }
                // we have to wait an undetermined amount of time to hear back from the gps to get location
                // so i used on recieve and after that info is delivered we can start fetching for fields by location
                guard !session.locationRecieved else {
                    return
                }
                
                // prevents us from doing this everytime we get new info from gps
                // thus we only load data the first time
                session.locationRecieved = true
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Olympsis")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        NotificationsView()
                            .environmentObject(session)
                    } label: {
                        Image(systemName: "bell")
                            .foregroundStyle(Color("foreground"))
                            .overlay {
                                if session.invitations.count > 0 {
                                    NotificationCountView(value: $session.invitations.count)
                                }
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    Home()
        .environmentObject(SessionStore())
}
