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
import AlertToast
import AuthenticationServices

struct ViewContainer: View {
    
    @State var currentTab: Tab = .home
    @State private var showOnboarding: Bool = false
    
    private var homeRouter = HomeRouter()
    @StateObject private var groupRouter = GroupRouter()
    @StateObject private var eventRouter = EventRouter()
    @StateObject private var profileRouter = ProfileRouter()
    
    @StateObject private var toastManager = ToastManager()
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
            currentTab = .map
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
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar)
                
                GroupView(router: groupRouter)
                    .tag(Tab.club)
                    .toolbar(.hidden, for: .tabBar)
                
                Events(router: eventRouter)
                    .tag(Tab.map)
                    .toolbar(.hidden, for: .tabBar)
                
                Activity()
                    .tag(Tab.activity)
                    .toolbar(.hidden, for: .tabBar)
                
                Profile()
                    .tag(Tab.profile)
                    .toolbar(.hidden, for: .tabBar)
            }
            .padding(.bottom, -10)
            
            TabBar(
                currentTab: $currentTab,
                homeRouter: homeRouter,
                groupRouter: groupRouter,
                eventRouter: eventRouter,
                profileRouter: profileRouter
            )
            .overlay(Rectangle().frame(height: 0.2).foregroundColor(.foreground), alignment: .top)
            .background(Color.Background.primary)
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
            guard let route = handleIncomingURL(url) else {
                return .systemAction
            }
            
            handleRoute(route)
            return .handled
        })
        .onOpenURL(perform: { url in
            guard let route = handleIncomingURL(url) else {
                return
            }
            
            handleRoute(route)
        })
        .task {
            session.state = .loading
            await session.CheckIn()
            guard let user = session.user else {
                await session.logout()
                return
            }
            
            await session.updateNotifications()
            
            // If the sessionStore has recieved a location the home page will handle all that when it recieves a location from the loc manager
            if (!session.locationRecieved) {
                if let hometown = user.hometown {
                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]))
                } else {
                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988))
                }
            }
            session.state = .success
            
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
