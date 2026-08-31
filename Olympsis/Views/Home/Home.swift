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
    
    @Binding var router: HomeRouter
    
    @State private var showDetail = false
    @State private var showMoreFields = false
    @State private var showRequestLocation: Bool = false
    
    @Environment(SessionStore.self) private var session
    
    private var hasLocation: Bool {
        return LocationManager.shared.isAuthorized
    }
    
    private var nextEvents: [Event] {
        guard let user = session.user,
              let userID = user.userID else {
            return []
        }
        return Array(session.events).rsvpedEvents(userID: userID)
    }
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "home_view")
    
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
                
                Spacer(minLength: 120)
                
            }
            .disabled(session.state == .loading)
            .redacted(reason: session.state == .loading ? .placeholder : [])
            .background(Color.Background.primary.ignoresSafeArea())
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Olympsis")
                            .fixedSize()
                            .italic()
                            .font(.custom("Archivo-Black", size: 25, relativeTo: .largeTitle))
                    }.sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Olympsis")
                            .fixedSize()
                            .italic()
                            .font(.custom("Archivo-Black", size: 25, relativeTo: .largeTitle))
                    }
                }
                
                if !hasLocation {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { self.showRequestLocation.toggle() }) {
                            Image(systemName: "location.slash")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { router.navigate(to: .upNextEvents(nextEvents))}) {
                        Image(systemName: "calendar")
                    }
// DISABLED FOR NOW
//                    Button(action: { router.navigate(to: .messages) }) {
//                        ZStack(alignment: .topTrailing) {
//                            Image(systemName: "bubble.left.and.bubble.right")
//                                .foregroundStyle(Color.Foreground.default)
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
                                .foregroundStyle(Color.Foreground.default)
                                
                            if session.unreadNotificationCount > 0 {
                                NotificationCountView(value: session.unreadNotificationCount)
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
            .navigationDestination(for: HOME_ROUTES.self, destination: { route in
                switch route {
                case .notifications:
                    NotificationsView()
                        .id(HOME_ROUTES.notifications)
                        .environment(router)
                        .environment(session)
                        .navigationBarBackButtonHidden()
                    
                case .archivedNotifications:
                    ArchivedNotificationsView()
                        .id(HOME_ROUTES.archivedNotifications)
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
                case .upNextEvents(let events):
                    UpNextEvents(events: events)
                        .id(HOME_ROUTES.upNextEvents(events))
                        .environment(session)
                }
            })
            .fullScreenCover(isPresented: $showRequestLocation, onDismiss: {
                Task {
                    await session.updateNotifications()
                }
            }) {
                LocationRequestView()
            }
        }
    }
}

#Preview {
    Home(router: .constant(HomeRouter()))
        .environment(SessionStore())
}
