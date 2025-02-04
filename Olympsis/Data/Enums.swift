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

enum AUTH_STATUS: String, CaseIterable {
    case unknown
    case not_finished
    case authenticated
    case unauthenticated
}

enum CONNECTION_STATE {
    case disconnected
    case connecting
    case connected
    case reconnecting
}

enum USER_STATUS: String, CaseIterable {
    case new
    case unknown
    case returning
    case not_finished
}

// MARK: - Navigation

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

enum URL_ACTIONS: String {
    case open_home = "open-home"
    case open_groups = "open-groups"
    case open_events = "open-events"
    case open_profile = "open-profile"
    
    case open_notifications = "open-notifications"
    case open_home_messages = "open-home-messages"
    case open_group_messages = "open-group-messages"
    
    case open_post_view = "open-post-view"
    case open_event_view = "open-event-view"
    
}

enum ROUTES: Codable, Hashable {
    case home(
        postId: String?=nil,
        openMessages: Bool?=nil,
        openNotifications: Bool?=nil
    )
    case groups
    case events(eventId: String?=nil, venueId: String?=nil)
    case profile
}

enum HOME_ROUTES: Codable, Hashable {
    case notifications
    case messages
    case full_post_view(_ postId: String)
}

enum GROUP_ROUTES: Codable, Hashable {
    case messages
    case newPost
    case newEvent
    case settings
}

enum GROUP_SETTINGS_ROUTES: Codable, Hashable {
    case edit
    case applications
    case reports
    case changeParent
    case members
}

enum EVENT_ROUTES: Codable, Hashable {
    case events(
        eventId: String?=nil,
        openEvents: Bool?=nil
    )
    case settings
}

enum PROFILE_ROUTES: String {
    case badges
    case trophies
}

enum PROFILE_SETTINGS_ROUTES: String {
    case notifications
    case bug_report
    case blocked_users
    case help
    case terms_of_use
    case privacy_policy
    case about_us
    case logs
}

/// Enum to denote loading state of an event/view
///
enum LOADING_STATE {
    case pending
    case loading
    case success
    case failure
}

enum VIEW_STATE {
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

// MARK: - Sports

enum SPORTS: String, CaseIterable {
    case soccer = "soccer"
    case running = "running"
    case cycling = "cycling"
    case volleyball = "volleyball"
    case basketball = "basketball"
    case pickleball = "pickleball"
    case racquetball = "racquetball"
    case tennis = "tennis"
    case golf = "golf"
    case hiking = "hiking"
    case climbing = "climbing"
    case spike = "spike"
    case football = "football"
    case weights = "weights"
    
    func icon() -> Image {
        switch self {
        case .soccer:
            return Image(systemName: "figure.soccer")
        case .running:
            return Image(systemName: "figure.run")
        case .cycling:
            return Image(systemName: "figure.outdoor.cycle")
        case .volleyball:
            return Image(systemName: "figure.volleyball")
        case .basketball:
            return Image(systemName: "figure.basketball")
        case .pickleball:
            return Image(systemName: "figure.pickleball")
        case .racquetball:
            return Image(systemName: "figure.racquetball")
        case .tennis:
            return Image(systemName: "figure.tennis")
        case .golf:
            return Image(systemName: "figure.golf")
        case .hiking:
            return Image(systemName: "figure.hiking")
        case .climbing:
            return Image(systemName: "figure.climbing")
        case .spike:
            return Image("logo-spikeball")
        case .football:
            return Image(systemName: "figure.american.football")
        case .weights:
            return Image(systemName: "figure.strengthtraining.traditional")
        }
    }
    
    func images() -> [String] {
        switch self {
        case .soccer:
            return ["event-images/soccer-0.jpg","event-images/soccer-1.jpg"]
        case .basketball:
            return ["event-images/basketball-0.jpg", "event-images/basketball-1.jpg", "event-images/basketball-2.jpg"]
        case .volleyball:
            return ["event-images/volleyball-0.jpg","event-images/volleyball-1.jpg","event-images/volleyball-2.jpg"]
        case .tennis:
            return ["event-images/tennis-0.jpg", "event-images/tennis-1.jpg", "event-images/tennis-2.jpg"]
        case .pickleball:
            return ["event-images/pickleball-0.jpg","event-images/pickleball-1.jpg","event-images/pickleball-2.jpg"]
        case .golf:
            return ["event-images/golf-0.jpg","event-images/golf-1.jpg","event-images/golf-2.jpg"]
        case .hiking:
            return ["event-images/hiking-0.jpg", "event-images/hiking-1.jpg"]
        case .climbing:
            return ["event-images/climbing-0.jpg","event-images/climbing-1.jpg","event-images/climbing-2.jpg"]
        case .spike:
            return ["event-images/spikeball-0.jpg"]
        case .running:
            return ["event-images/running-0.jpg", "event-images/running-1.jpg"]
        case .cycling:
            return ["event-images/cycling-0.jpg", "event-images/cycling-1.jpg"]
        case .racquetball:
            return ["event-images/racquetball-0.jpg"]
        case .football:
            return ["event-images/football-0.jpg"]
        case .weights:
            return ["event-images/weights-0.jpg", "event-images/weights-1.jpg"]
        }
    }
    
    func getName() -> String {
        switch self {
        case .soccer:
            return "Soccer"
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .volleyball:
            return "Volleyball"
        case .basketball:
            return "Basketball"
        case .pickleball:
            return "Pickleball"
        case .racquetball:
            return "Racquetball"
        case .tennis:
            return "Tennis"
        case .golf:
            return "Golf"
        case .hiking:
            return "Hiking"
        case .climbing:
            return "Climbing"
        case .spike:
            return "Spike"
        case .football:
            return "Football"
        case .weights:
            return "Weights"
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
    
    func toInt() -> Int {
        switch self {
        case .Club:
            0
        case .Organization:
            1
        }
    }
}

func numberToGroupType(number: Int) -> GROUP_TYPE {
    if (number == 0) {
        return .Club
    } else {
        return .Organization
    }
}

enum EVENT_RSVP_STATUS: String, CaseIterable {
    case Yes = "yes"
    case Maybe = "maybe"
}

func numberToEventRSVPStatus(_ number: Int) -> EVENT_RSVP_STATUS {
    if (number == 0) {
        return .Yes
    } else {
        return .Maybe
    }
}

enum EVENT_VISIBILITY_TYPES: String, CaseIterable {
    case Public = "public"
    case Group = "group"
    case Private = "private"
    
    func toInt() -> Int {
        switch self {
        case .Public:
            0
        case .Group:
            1
        case .Private:
            2
        }
    }
}

func numberToEventVisibilityType(_ number: Int) -> EVENT_VISIBILITY_TYPES {
    switch number {
    case 0:
        return .Public
    case 1:
        return .Group
    default:
        return .Private
    }
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

func numberToEventSkillLEvel(number: Int) -> EVENT_SKILL_LEVELS {
    switch number {
    case 0:
        return .All
    case 1:
        return .Beginner
    case 2:
        return .Amateur
    default:
        return .Expert
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
    
    func toInt() -> Int {
        switch self {
        case .PickUp:
            return 0
        case .Tournament:
            return 1
        }
    }
}

func numberToEventType(number: Int) -> EVENT_TYPES {
    if number == 1 {
        return .Tournament
    } else {
        return .PickUp
    }
}


enum FIELD_TYPES: String {
    case Internal = "internal"
    case External = "external"
}

enum RSVP_STATUS: String {
    case Going = "yes"
    case Maybe = "maybe"
}

enum POST_TYPE: String {
    case Post = "post"
    case Announcement = "announcement"
    case Advertisement = "advertisement"
}

enum NEW_POST_TYPE: String {
    case Post = "post"
    case Announcement = "announcement"
}

enum POST_PRIMARY_CONTENT {
    case Text
    case Event
    case Activity
}

enum IMAGE_SIZING: String {
    case PROFILE = "200x200"
    case LANDSCAPE = "1080x566"
    case SQUARE = "1080x1080"
}

enum MediaUploadError: Error {
    case innapropriateContent
    case unexpected(_ reason: String)
}

enum CREATE_ERROR: Error {
    case unexpected
    case noName
}

enum SCALE {
    case Small
    case Medium
    case Large
	case XLarge
}

// MARK: - Event Sharing

enum SHARING_TITLE_POSITION {
    case top_leading
    case top_trailing
    case top_center
    case center
    case bottom_center
    case bottom_leading
    case bottom_trailing
}

enum SHARING_TIME_POSITION {
    case top_leading
    case top_trailing
    case top_center
    case center
    case bottom_center
    case bottom_leading
    case bottom_trailing
}

enum SHARING_VENUE_POSITION {
    case top_leading
    case top_trailing
    case top_center
    case center
    case bottom_center
    case bottom_leading
    case bottom_trailing
}

enum SHARE_METHOD {
    case image
    case facebook
    case instagram
    case x
}

enum APP_MODE: Int, CaseIterable {
    case free = 0
    case premium = 1
}

enum APP_STATE: Int, CaseIterable {
    case normal = 0
    case developer = 1
    case suspended = 2
}

enum BADGE_SIZE {
    case small
    case medium
    case large
}

// MARK: - Notifications

public enum TOAST_POSITION: String {
    case top = "top"
    case bottom = "bottom"
}

enum TOAST_TYPE: String {
    case post = "post"
    case event = "event"
    case group = "group"
    case friend = "friend"
    case status = "status"
    case message = "message"
}

enum POST_TOAST_TYPES: String {
    case newPost = "new_post"
    case like = "like"
    case comment = "comment"
}

enum EVENT_TOAST_TYPES: String {
    case newEvent = "new_event"
    case eventInvite = "event_invite"
    case eventsSummary = "events_summary"
    case eventStatus = "event_status"
    case eventParticipantStatus = "event_participant_status"
}

enum GROUP_TOAST_TYPES: String {
    case newReport = "new_report"
    case newApplication = "new_application"
    case applicationStatus = "application_status"
}

enum FRIEND_TOAST_TYPES: String {
    case newRequest = "new_request"
}

enum STATUS_TOAST_TYPES: String {
    case warning = "warning"
    case success = "success"
    case error = "error"
}

enum MESSAGE_TOAST_TYPES: String {
    case messageRequest = "message_request"
    case newMessage = "new_message"
    case newGroupMessage = "new_group_message"
    case addedToGroup = "added_to_group"
    case removedFromGroup = "removed_from_group"
}
