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
    
    @State public var router: HomeRouter
    
    @State private var showDetail = false
    @State private var showMoreFields = false
    
    @Environment(SessionStore.self) private var session
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "home_view")
    
    init(router: HomeRouter = HomeRouter()) {
        self._router = .init(initialValue: router)
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            ScrollView(.vertical) {
                
                //MARK: - Welcome message
                WelcomeCard()
                    .padding(.top, 25)
                    .environment(session)
                
                // MARK: - Next Event
                NextEvent()
                    .padding(.top)
                    .environment(session)
                
                // MARK: - Quick Actions
                QuickActions()
                    .padding(.top)
                    .environment(session)
                
                // MARK: - Announcements
                AnnouncementsView()
                    .environment(session)
                
                // MARK: - Hot Events
                HotEvents()
                    .environment(session)
                
                // MARK: - Nearby Venues
                NearbyVenues()
                    .environment(session)
                
                Spacer(minLength: 100)
                
            }
            .disabled(session.state == .loading)
            .redacted(reason: session.state == .loading ? .placeholder : [])
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Olympsis")
                        .italic()
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
// DISABLED FOR NOW
//                    Button(action: { router.navigate(to: .messages) }) {
//                        ZStack(alignment: .topTrailing) {
//                            Image(systemName: "bubble.left.and.bubble.right")
//                                .foregroundStyle(Color.foreground)
//                            
//                            if session.invitations.count > 0 {
//                                NotificationCountView(value: $session.invitations.count)
//                            }
//                        }
//                    }
//                    .id(UUID())
//                    .disabled(session.state == .loading)
//                    .redacted(reason: session.state == .loading ? .placeholder : [])
                    
                    Button(action: { router.navigate(to: .notifications) }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .foregroundStyle(Color.foreground)
                                
                            if session.invitations.count > 0 {
                                NotificationCountView(value: session.invitations.count)
                            }
                        }
                    }
                    .id(UUID())
                    .disabled(session.state == .loading)
                    .redacted(reason: session.state == .loading ? .placeholder : [])
                }
            }
            .toolbarRole(.navigationStack)
            .ignoresSafeArea(.keyboard)
            .ignoresSafeArea(.container, edges: .bottom)
            .background(Color.Background.primary)
            .navigationDestination(for: HOME_ROUTES.self, destination: { route in
                switch route {
                case .notifications:
                    NotificationsView()
                        .id(HOME_ROUTES.notifications)
                        .environment(router)
                        .environment(session)
                        .navigationBarBackButtonHidden()
                    
                case .messages:
                    HomeMessagesView()
                        .id(HOME_ROUTES.messages)
                        .environment(router)
                        .environment(session)
                        .navigationBarBackButtonHidden()
                    
                case .full_post_view(let id):
                    AsyncPostView(postId: id)
                        .id(HOME_ROUTES.full_post_view(id))
                        .environment(session)
                        .navigationBarBackButtonHidden()
                }
            })
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
        }
    }
}

#Preview {
    Home()
        .environment(SessionStore())
}
