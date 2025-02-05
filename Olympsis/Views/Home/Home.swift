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
    
    @EnvironmentObject private var session: SessionStore
    
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
                                NotificationCountView(value: $session.invitations.count)
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
            .background(Color("background-color/primary"))
            .navigationDestination(for: HOME_ROUTES.self, destination: { route in
                switch route {
                case .notifications:
                    NotificationsView()
                        .id(HOME_ROUTES.notifications)
                        .environment(router)
                        .environmentObject(session)
                        .navigationBarBackButtonHidden()
                    
                case .messages:
                    HomeMessagesView()
                        .id(HOME_ROUTES.messages)
                        .environment(router)
                        .environmentObject(session)
                        .navigationBarBackButtonHidden()
                    
                case .full_post_view(let id):
                    AsyncPostView(postId: id)
                        .id(HOME_ROUTES.full_post_view(id))
                        .environmentObject(session)
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
        .environmentObject(SessionStore())
}
