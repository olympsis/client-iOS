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
    
    @State private var locationTask: Task<Void, Never>? = nil
    
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
            
            // Load workouts if user has authorized us
//            if session.workoutManager.checkAuthorizationStatus() {
//                group.addTask {
//                    _ = await session.workoutManager.loadWorkouts()
//                }
//            }
        }
    }
    
    /// Sets up a task that waits about 1 seconds before triggering
    /// - Makes sure that we are still waiting on the location updates
    /// - If the user has a hometown we use that fallback
    /// - If not then we use the generic location fallback
//    private func setUpLocationFallback() {
//        locationTask = Task {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
//                Task { @MainActor in
//                    guard session.state == .loading else { return }
//                    guard let hometown = session.user?.hometown else {
////                        await session.getNearbyData(location: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988))
//                        session.state = .success
//                        return
//                    }
//                    
////                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0]))
//                    session.state = .success
//                }
//            }
//        }
//    }
    
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
        VStack {
            if #available(iOS 26.0, *) {
                TabView(selection: $currentTab) {
                    Tab("", systemImage: "calendar", value: .events) {
                        Events(router: $eventRouter)
                            .tag(ViewTab.events)
                            .environment(session)
                    }
                    
                    Tab("", systemImage: "person.circle", value: .profile) {
                        Profile()
                            .tag(ViewTab.profile)
                            .environment(session)
                    }
                }
            } else {
                TabView(selection: $currentTab) {
                    Home(router: $homeRouter)
                        .tag(ViewTab.home)
                        .toolbar(.hidden, for: .tabBar)
                        .environment(session)
                    
                    GroupView(router: $groupRouter)
                        .tag(ViewTab.club)
                        .toolbar(.hidden, for: .tabBar)
                        .environment(session)
                    
                    Events(router: $eventRouter)
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
        .onOpenURL(perform: { url in // Handle both internal and external urls
            guard let route = url.scheme == "olympsis" ? handleInternalURL(url) : handleExternalURL(url) else {
                return
            }
            
            handleRoute(route)
        })
        .notificationSystem(manager: NotificationManager.shared)
//        .onReceive(LocationManager.shared.location.publisher, perform: { location in
//            // Triggered on any signification location changes update
//            // We cancel the previously set location task and use our recent location
//            guard session.state == .loading else { return }
//            
//            locationTask?.cancel()
//            Task { @MainActor in
//                // Will want to add saved added sports here later
////                guard let user = session.user else { return }
////                await session.getNearbyData(location: location, selectedSports: user.sports)
//                
//                session.state = .success
//            }
//        })
        .task {
            session.state = .loading

            // Sets up navigation handler for notifications
            NotificationManager.shared.navigationHandler = { url in
                if let route = handleInternalURL(url) {
                    handleRoute(route)
                }
            }

            // Fetch fresh user data and notifications from the server
            await initializeUpCheckInTasks()

            // GPS Location updates fallback
//            setUpLocationFallback()

            // Onboarding
            handleOnboardingSheet()
        }
    }
}

#Preview {
    ViewContainer()
        .environment(SessionStore())
}

