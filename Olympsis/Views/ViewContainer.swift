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
    
    @State var currentTab: ViewTab = .events
    @State private var showOnboarding: Bool = false
    
    @State private var homeRouter = HomeRouter()
    @State private var groupRouter = GroupRouter()
    @State private var eventRouter = EventRouter()
    @State private var profileRouter = ProfileRouter()

    @Environment(SessionStore.self) private var session

    /// Handles routing to the various tabs in the navigation bar
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
    
    /// Kicks off the tasks needed to check the user into Olympsis.
    /// Launches a task group to run these tasks in parallel.
    /// - Checks in with the server and get's updated user data
    /// - Fetches the user's notifications
    /// - Loads workouts if user allowed us to
    private func initializeUpCheckInTasks() async {
        await withTaskGroup(of: Void.self) { group in
            
            // Check-In Task
            group.addTask {
                await session.checkIn()
                guard await session.user != nil else {
                    await session.logout()
                    return
                }
            }
            
            // Fetch user's notifications
            group.addTask {
                await session.getNotifications()
            }
            
        }
    }
    
    /// If the user hasn't onboarded this will trigger the onboarding sheet to show.
    private func handleOnboardingSheet() {
        guard let hasOnboarded = session.user?.hasOnboarded else {
            return
        }
        if !hasOnboarded {
            showOnboarding.toggle()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentTab) {
                Events(router: $eventRouter)
                    .tag(ViewTab.events)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)

                Profile()
                    .tag(ViewTab.profile)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
            }

            VStack(spacing: 0) {
                Spacer()
                TabBar(
                    currentTab: $currentTab,
                    eventRouter: eventRouter,
                    profileRouter: profileRouter
                )
            }.ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            Task {
                session.user?.hasOnboarded = true
                _ = await session.userObserver.updateUserData(update: UserDao(hasOnboarded: true))
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
        .onOpenURL(perform: { url in // Handle both internal and external urls
            guard let route = url.scheme == "olympsis" ? handleInternalURL(url) : handleExternalURL(url) else {
                return
            }
            
            handleRoute(route)
        })
        .notificationSystem(manager: NotificationManager.shared)
        .task {
            session.state = .loading

            // Sets up navigation handler for notifications
            NotificationManager.shared.navigationHandler = { url in
                if let route = handleInternalURL(url) {
                    handleRoute(route)
                }
            }

            // Flush any deep link captured from a notification tap that
            // cold-launched the app before this handler existed.
            NotificationManager.shared.flushPendingNavigation()

            // Fetch fresh user data and notifications from the server
            await initializeUpCheckInTasks()

            // Onboarding
            handleOnboardingSheet()
        }
    }
}

#Preview {
    ViewContainer()
        .environment(SessionStore())
}

