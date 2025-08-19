//
//  ContentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import MapKit
import SwiftUI
import Firebase
import Security
import AuthenticationServices

struct ViewContainer: View {
    
    @State var currentTab: ViewTab = .home
    @State private var showOnboarding: Bool = false
    
    private var homeRouter = HomeRouter()
    @StateObject private var groupRouter = GroupRouter()
    @StateObject private var eventRouter = EventRouter()
    @StateObject private var profileRouter = ProfileRouter()
    
//    @StateObject private var toastManager = ToastManager()
    @Environment(SessionStore.self) private var session

    func handleRoute(_ route: ROUTES) {
        switch route {
        case .home:
            currentTab = .home
            handleHomeURL(route, router: homeRouter)
        case .groups:
            currentTab = .club
            handleGroupsURL(route, router: groupRouter)
        case .events:
            currentTab = .events
            handleEventsURL(route, router: eventRouter)
        case .profile:
            currentTab = .profile
            handleProfileURL(route, router: profileRouter)
        }
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                Home(router: homeRouter)
                    .tag(ViewTab.home)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
                
                GroupView(router: groupRouter)
                    .tag(ViewTab.club)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
                
                Events(router: eventRouter)
                    .tag(ViewTab.events)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
                
                Activities()
                    .tag(ViewTab.activity)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
                    .environment(session.workoutManager)
                
                Profile()
                    .tag(ViewTab.profile)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
            }
            .padding(.bottom, -10)
            
            TabBar(
                currentTab: $currentTab,
                homeRouter: homeRouter,
                groupRouter: groupRouter,
                eventRouter: eventRouter,
                profileRouter: profileRouter
            )
            .overlay(Rectangle().frame(height: 0.2).foregroundColor(.foreground).padding(.top, 2), alignment: .top)
            .ignoresSafeArea(.keyboard)
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            Task {
                session.user?.hasOnboarded = true
                _ = await session.userObserver.UpdateUserData(update: UserDao(hasOnboarded: true))
            }
        }, content: {
            Onboarding()
        })
        .environment(\.openURL, OpenURLAction { url in // Handles internal URLS
            guard let route = handleInternalURL(url) else {
                return .systemAction
            }
            
            handleRoute(route)
            return .handled
        })
        .onOpenURL(perform: { url in
            // Handle both internal and external urls
            guard let route = url.scheme == "olympsis" ? handleInternalURL(url) : handleExternalURL(url) else {
                return
            }
            
            handleRoute(route)
        })
        .notificationSystem(manager: NotificationManager.shared)
        .onAppear {
            // Set up navigation handler for notifications
            NotificationManager.shared.navigationHandler = { url in
                if let route = handleInternalURL(url) {
                    handleRoute(route)
                }
            }
        }
        .task {
            session.state = .loading
            await session.CheckIn()
            guard let user = session.user else {
                await session.logout()
                return
            }
            
            await session.updateNotifications()
            await session.getNotifications()
            
            // If the sessionStore has recieved a location the home page will handle all that when it recieves a location from the loc manager
            if (!session.locationRecieved) {
                if let hometown = user.hometown {
                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]))
                } else {
                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988))
                }
            }
            session.state = .success

            if session.workoutManager.checkAuthorizationStatus() {
                _ = await session.workoutManager.loadWorkouts()
            }
            
            guard let hasOnboarded = user.hasOnboarded else {
                return
            }
            if !hasOnboarded {
                showOnboarding.toggle()
            }
        }
    }
}

#Preview {
    ViewContainer()
        .environment(SessionStore())
}
