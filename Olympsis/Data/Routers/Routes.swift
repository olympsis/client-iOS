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
        return ROUTES.home
        
    case URL_ACTIONS.open_groups.rawValue:
        return ROUTES.groups
        
    case URL_ACTIONS.open_events.rawValue:
        return ROUTES.events
        
    case URL_ACTIONS.open_profile.rawValue:
        return ROUTES.profile
        
    default:
        return nil
    }
}

func handleHomeURL(_ url: URL) -> HOME_ROUTES? {
    return nil
}

func handleGroupsURL(_ url: URL) -> GROUP_ROUTES? {
    return nil
}

func handleEventsURL(_ url: URL) -> EVENTS_ROUTES? {
    return nil
}

func handleProfileURL(_ url: URL) -> PROFILE_ROUTES? {
    return nil
}
