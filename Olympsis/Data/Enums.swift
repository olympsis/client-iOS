//
//  Enums.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import SwiftUI
import Foundation

enum ACCOUNT_STATE {
    case Authorized
    case Revoked
    case NotFound
    case Transferred
    case Unknown
    case Incomplete
}

enum AUTH_STATUS {
    case unknown
    case not_finished
    case authenticated
    case unauthenticated
}

enum USER_STATUS {
    case new
    case unknown
    case returning
    case not_finished
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
    case spikeball = "spike"
    
    func Icon() -> Image {
        switch self {
        case .soccer:
            return Image(systemName: "figure.soccer")
        case .volleyball:
            return Image(systemName: "figure.volleyball")
        case .basketball:
            return Image(systemName: "figure.basketball")
        case .pickleball:
            return Image(systemName: "figure.pickleball")
        case .tennis:
            return Image(systemName: "figure.tennis")
        case .golf:
            return Image(systemName: "figure.golf")
        case .hiking:
            return Image(systemName: "figure.hiking")
        case .climbing:
            return Image(systemName: "figure.climbing")
        case .spikeball:
            return Image("logo-spikeball")
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
        case .spikeball:
            return ["spikeball-0"]
        }
    }
}

enum MEMBER_ROLES: String, CaseIterable {
    case Owner = "owner"
    case Admin = "admin"
    case Moderator = "moderator"
    case Member = "member"
}


enum GROUP_TYPE: String, CaseIterable {
    case Club = "club"
    case Organization = "organization"
}

enum EVENT_VISIBILITY_TYPES: String, CaseIterable {
    case Public = "public"
    case Private = "private"
    case Group = "group"
}

enum EVENT_SKILL_LEVELS: String, CaseIterable {
    case All = "Any Level"
    case Beginner = "Beginner"
    case Amateur = "Amateur"
    case Expert = "Expert"
    
    func toInt() -> Int {
        switch self {
        case .All:
            0
        case .Beginner:
            1
        case .Amateur:
            2
        case .Expert:
            3
        }
    }
}

enum NEW_EVENT_ERROR: Error {
    case unexpected
    case noTitle
    case noDescription
    case noSelectedField
}

enum SkillLevel: String, CaseIterable {
    case any = "Any Level"
    case beginner   = "Beginner"
    case amateur    = "Amateur"
    case expert     = "Expert"
}

enum EVENT_TYPES: String, CaseIterable {
    case PickUp = "pickup"
    case Tournament = "tournament"
}

enum FIELD_TYPES: String {
    case Internal = "internal"
    case External = "external"
}

enum RSVP_STATUS: String {
    case Going = "going"
    case Maybe = "maybe"
}
