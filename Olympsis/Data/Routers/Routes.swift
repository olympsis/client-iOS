//
//  Routes.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import Foundation

/// Handle external and internal urls within the application
///
/// We want the urls triggering the app to open to have the right format.
/// Then we route to the appropriate view based on the url and it's query parameters
func handleIncomingURL(_ url: URL) -> ROUTES? {
    guard url.scheme == "olympsis" else {
        return nil
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        print("Invalid URL")
        return nil
    }
    
    guard let action = components.host else {
        print("Unknown URL, we can't handle this one!")
        return nil
    }
    
    switch action {
    case URL_ACTIONS.open_home.rawValue:
        return ROUTES.home()
        
    case URL_ACTIONS.open_groups.rawValue:
        return ROUTES.groups
        
    case URL_ACTIONS.open_events.rawValue:
        guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            return ROUTES.events()
        }
        return ROUTES.events(id: id)
        
    case URL_ACTIONS.open_profile.rawValue:
        return ROUTES.profile
    
    case URL_ACTIONS.open_post_view.rawValue:
        guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Invalid URL: no post ID")
            return ROUTES.home()
        }
        return ROUTES.home(postId: id)
        
    case URL_ACTIONS.open_event_view.rawValue:
        guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Invalid URL: no event ID")
            return ROUTES.events()
        }
        return ROUTES.events(id: id)
        
    case URL_ACTIONS.open_notifications.rawValue:
        return ROUTES.home(openNotifications: true)
        
    case URL_ACTIONS.open_home_messages.rawValue:
        return ROUTES.home(openMessages: true)
        
    default:
        return nil
    }
}

@MainActor
func handleHomeURL(_ route: ROUTES, router: HomeRouter) {
    router.navigateToRoot()
    switch route {
    case .home(let postId, let openMessages, let openNotifications):
        if let postId {
            router.navigate(to: .full_post_view(postId))
            return
        }
        if openMessages != nil  && openMessages == true {
            router.navigate(to: .messages)
            return
        }
        if openNotifications != nil && openNotifications == true {
            router.navigate(to: .notifications)
            return
        }
    case .groups, .events, .profile:
        return
    }
}

@MainActor
func handleGroupsURL(_ route: ROUTES, router: GroupRouter) {
    router.navigateToRoot()
    switch route {
    case .home, .events, .profile:
        return
    case .groups:
        return
    }
}

@MainActor
func handleEventsURL(_ route: ROUTES, router: EventRouter) {
    router.navigateToRoot()
    switch route {
    case .home, .groups, .profile:
        return
    case .events(let id, _):
        if let id {
            router.navigate(to: .events(ID: id))
        }
        return
    }
}

@MainActor
func handleProfileURL(_ route: ROUTES, router: ProfileRouter) {
    router.navigateToRoot()
    switch route {
    case .home, .groups, .events:
        return
    case .profile:
        return
    }
}
