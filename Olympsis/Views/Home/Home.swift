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
    @State private var showNotifications = false
    
    @EnvironmentObject private var session: SessionStore
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "home_view")
    
    private var name: String {
        guard let user = session.user, let name = user.firstName else {
            log.error("Failed to get user's name")
            return ""
        }
        return name
    }
    
    private var event: Event? {
        guard let user = session.user,
              let uuid = user.uuid else {
            return nil
        }
        
        return session.events.mostRecentForUser(uuid: uuid)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    
                    //MARK: - Welcome message
                    HStack {
                        VStack(alignment: .leading){
                            WelcomeView(name: name, status: $session.state)
                        }.padding(.top, 25)
                        Spacer()
                    }
                    
                    if let e = event {
                        if session.state == .success {
                            VStack (alignment: .center){
                                EventListItem(event: e)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // MARK: - Announcements
                    HStack{
                        VStack(alignment: .leading){
                            Text(String(localized: "Announcements", table: "General"))
                                .font(.custom("Helvetica Neue", size: 17))
                                .bold()
                                .padding()
                            AnnouncementsView(status: $session.state)
                                .environmentObject(session.feedObserver)
                        }
                    }
                    
                    // MARK: - Hot Events
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
                    
                    // MARK: - Nearby Venues
                    HStack {
                        VStack(alignment: .leading){
                            HStack {
                                Text(String(localized: "Nearby Venues", table: "General"))
                                    .font(.system(.headline))
                                .padding()
                                Spacer()
                                Button(action:{ self.showMoreFields.toggle() }){
                                    Text(String(localized: "View All", table: "General"))
                                       .bold()
                                    Image(systemName: "chevron.down")
                                }.padding()
                                    .foregroundColor(Color.primary)
                            }.fullScreenCover(isPresented: $showMoreFields) {
                                VenuesList(venues: session.venues)
                            }
                            
                            Venues(venues: $session.venues, status: $session.state)
                        }
                    }.onReceive(session.locationManager.$location) { newLoc in
                        
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
                        
                    }.padding(.bottom, 100)
                }.fullScreenCover(isPresented: $showNotifications, content: {
                    NotificationsView()
                })
                
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Olympsis")
                        .font(.custom("ITCAvantGardeStd-Bold", size: 30, relativeTo: .largeTitle))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{ self.showNotifications.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 45, height: 35)
                                .foregroundStyle(Color("background"))
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
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(SessionStore())
    }
}
