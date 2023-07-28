//
//  Enums.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import Foundation

enum ACCOUNT_STATE {
    case Authorized
    case Revoked
    case NotFound
    case Transferred
    case Unknown
    case Incomplete
}

enum USER_STATUS {
    case New
    case Banned
    case Ubanned
    case Returning
    case Unknown
}

enum Tab: String, CaseIterable {
    case home = "Home"
    case club = "Club"
    case map = "Map"
    case activity = "Activity"
    case profile = "Setting"
}

enum AuthTab: String, CaseIterable {
    case auth = "AUTH"
    case username = "USERNAME"
    case sports = "SPORTS"
    case location = "LOCATION"
    case notifications = "NOTIFICATIONS"
}


enum NavigationType: String, Hashable {
    case home = "HOME"
    case clubs = "CLUBS"
    case map = "MAP"
    case settings = "SETTINGS"
}


enum AuthNavigation: String, Hashable {
    case auth = "AUTH"
    case new = "NEW"
    case home = "HOME"
    case permissions = "PERMISSIONS"
    
}

/// Enum to denote loading state of an event/view
///
enum LOADING_STATE {
    case pending
    case loading
    case success
    case failure
}

enum EVENT_STATUS: String {
    case pending = "pending"
    case in_progress = "in-progress"
    case completed = "ended"
}


enum SPORT: String, CaseIterable {
    case soccer = "soccer"
    case volleyball = "volleyball"
    case basketball = "basketball"
    case pickleball = "pickleball"
    case tennis = "tennis"
    case golf = "golf"
    case hiking = "hiking"
    case climbing = "climbing"
    
    func Icon() -> String {
        switch self {
        case .soccer:
            return "⚽️"
        case .volleyball:
            return "🏐"
        case .basketball:
            return "🏀"
        case .pickleball:
            return "🏏"
        case .tennis:
            return "🎾"
        case .golf:
            return "⛳️"
        case .hiking:
            return "⛰️"
        case .climbing:
            return "🧗‍♂️"
        }
    }
    
    func Images() -> [String] {
        switch self {
        case .soccer:
            return ["soccer-0","soccer-1"]
        case .basketball:
            return ["basketball-0", "basketball-1", "basketball-2"]
        case .volleyball:
            return ["volleyball-0","volleyball-1","volleyball-2"]
        case .tennis:
            return ["tennis-0", "tennis-1", "tennis-2"]
        case .pickleball:
            return ["pickleball-0","pickleball-1","pickleball-2"]
        case .golf:
            return ["golf-0","golf-1","golf-2"]
        case .hiking:
            return ["hiking-0", "hiking-1"]
        case .climbing:
            return ["climbing-0","climbing-1","climbing-2"]
        }
    }
}

enum MEMBER_ROLES: String, CaseIterable {
    case Owner = "owner"
    case Admin = "admin"
    case Moderator = "moderator"
    case Member = "member"
}
