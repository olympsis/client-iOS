//
//  Routes.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import Foundation

/// Handle  internal urls within the application
///
/// We want the internal urls triggering the app to open to have the right format.
/// Then we route to the appropriate view based on the url and it's query parameters
func handleInternalURL(_ url: URL) -> ROUTES? {
    guard url.scheme == "olympsis" else {
        return nil
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        #if DEBUG
        print("Invalid URL")
        #endif
        return nil
    }

    guard let action = components.host else {
        #if DEBUG
        print("Unknown URL, we can't handle this one!")
        #endif
        return nil
    }
    
    switch action {
    case URL_ACTIONS.open_home.rawValue:
        return ROUTES.home()
        
    case URL_ACTIONS.open_groups.rawValue:
        return ROUTES.groups()
        
    case URL_ACTIONS.open_events.rawValue:
        guard let id = components.queryItems?.first(where: { $0.name == "ID" })?.value else {
            return ROUTES.events()
        }
        return ROUTES.events(id: id)
        
    case URL_ACTIONS.open_profile.rawValue:
        return ROUTES.profile
    
    case URL_ACTIONS.open_post_view.rawValue:
        guard let id = components.queryItems?.first(where: { $0.name == "ID" })?.value else {
            #if DEBUG
            print("Invalid URL: no post ID")
            #endif
            return ROUTES.home()
        }
        return ROUTES.home(postId: id)
        
    case URL_ACTIONS.open_event_view.rawValue:
        guard let id = components.queryItems?.first(where: { $0.name == "ID" })?.value else {
            #if DEBUG
            print("Invalid URL: no event ID")
            #endif
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

/// Handle external urls
///
/// We want the external urls to be handled properly. To open up the app and go to the right views.
/// For now we will only handle events and groups external urls.
/// That way events and groups can be shared and opened within the app if installed.
func handleExternalURL(_ url: URL) -> ROUTES? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        #if DEBUG
        print("Invalid external URL")
        #endif
        return nil
    }
    
    // Break down url path
    let parts = components.path.components(separatedBy: "/").filter { !$0.isEmpty }
    guard let page = parts.first else {
        return nil
    }
    
    // Handle pages: events | groups
    switch page {
    case "events":
        guard let id = parts.dropFirst().first else {
            return ROUTES.events()
        }
        return ROUTES.events(id: id)
    case "groups":
        guard let id = parts.dropFirst().dropFirst().first else {
            return ROUTES.groups()
        }
        return ROUTES.groups(id: id)
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
    switch route {
    case .home, .events, .profile:
        return
    case .groups(let id):
        guard let id else {
            return router.navigateToRoot()
        }
        return router.navigate(to: .clubsList(id: id))
    }
}

@MainActor
func handleEventsURL(_ route: ROUTES, router: EventRouter) {
    router.navigateToRoot()
    switch route {
    case .home, .groups, .profile:
        return
    case .events(let id, _):
        guard let id else {
            return router.navigateToRoot()
        }
        return router.navigate(to: .events(ID: id))
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
