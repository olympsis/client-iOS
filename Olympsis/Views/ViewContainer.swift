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
import Kingfisher
import AuthenticationServices

struct ViewContainer: View {
    
    @State var currentTab: ViewTab = .home
    @State private var showOnboarding: Bool = false
    
    @State private var homeRouter = HomeRouter()
    @State private var groupRouter = GroupRouter()
    @State private var eventRouter = EventRouter()
    @State private var profileRouter = ProfileRouter()
    @State private var eventSearchManager = SearchManager()
    @State private var eventsViewModel = EventsViewModel()

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
    
    /// Prepares the shared event-search state from the completed check-in,
    /// then fetches both resources around the best available location. This
    /// never requests location permission; Events owns that user-facing prompt.
    private func loadEventsAndVenues() async {
        eventSearchManager.tags = session.tags
        eventSearchManager.sports = session.sports
        eventsViewModel.tags = session.tags
        eventsViewModel.sports = session.sports

        // First-launch seed: preserve saved filters when present, otherwise
        // start with the person's preferred sports from their check-in data.
        if !eventSearchManager.hasPersistedSelections,
           let sports = session.user?.sports {
            eventSearchManager.selectedSports = sports
            eventSearchManager.persistSelections()
        }

        eventsViewModel.selectedSports = eventSearchManager.selectedSports
        eventsViewModel.selectedTags = eventSearchManager.selectedTags

        // Existing authorization can yield a fresh fix without a prompt. If
        // no fix arrives within a second, EventsViewModel uses hometown (or
        // its built-in default) for this initial fetch.
        LocationManager.shared.startUpdatingLocationIfAuthorized()
        _ = await LocationManager.shared.waitForLocation(timeout: 1.0)
        await eventsViewModel.fetchData(session)
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
                Home(router: $homeRouter)
                    .tag(ViewTab.home)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
                
                Events(router: $eventRouter)
                    .tag(ViewTab.events)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
                    .environment(eventSearchManager)
                    .environment(eventsViewModel)

                Profile()
                    .tag(ViewTab.profile)
                    .toolbar(.hidden, for: .tabBar)
                    .environment(session)
            }

            VStack(spacing: 0) {
                Spacer()
                TabBar(
                    currentTab: $currentTab,
                    homeRouter: homeRouter,
                    eventRouter: eventRouter,
                    profileRouter: profileRouter
                )
            }.ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            Task {
                session.user?.hasOnboarded = true
                _ = await session.userService.updateUserData(update: UserDao(hasOnboarded: true))
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
        .inAppNotifications(.shared, style: .olympsis)
        // Route the kit's remote images through Kingfisher so toast
        // avatars/thumbnails share the app's existing image cache.
        .inAppNotificationImageLoader(.init { url in
            AnyView(KFImage(url).cacheOriginalImage().resizable())
        })
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

            // Fetch fresh user data and notifications from the server.
            await initializeUpCheckInTasks()

            // Once check-in has supplied the user's filters and fallback
            // hometown, fetch events and venues together.
            await loadEventsAndVenues()

            // Nothing ever flipped this back after start-up (the old reset was
            // deleted in the fatal-error pruning pass), which left Home
            // permanently redacted/disabled. Mark the session ready here.
            session.state = .success

            // Onboarding
            handleOnboardingSheet()
        }
    }
}

#Preview {
    ViewContainer()
        .environment(SessionStore())
}

