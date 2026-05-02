//
//  Enums.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import SwiftUI
// import HealthKit
// import WorkoutKit
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
    case fatal_error
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

enum ViewTab: String, CaseIterable {
    case home = "Home"
    case club = "Club"
    case events = "Events"
    case activity = "Activity"
    case profile = "Setting"
}

enum AuthTab: String, CaseIterable {
    case auth = "AUTH"
    case info = "USER_INFO"
    case sports = "USER_SPORTS"
}

enum EVENTS_PAGE_STATE: String, CaseIterable {
    case list
    case map
}

enum EVENT_RECURRENCE_FREQUENCY: String, CaseIterable {
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
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
    case open_home = "home"
    case open_groups = "groups"
    case open_events = "events"
    case open_profile = "profile"

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
    case groups(id: String?=nil)
    case events(id: String?=nil, venueId: String?=nil)
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
    case clubMenu

    case clubsList(id: String?=nil)
    case clubsMenu
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
        ID: String?=nil,
        openEvents: Bool?=nil
    )
    case event(event: Event)
    case upNextEvents(events: [Event])
    case new
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
    case live = "live"
    case ended = "ended"
}

// MARK: - Sports

enum SUPPORTED_SPORTS: String, CaseIterable {

    case running = "running"
    case walking = "walking"
    case cycling = "cycling"
    case soccer = "soccer"
    case weights = "weights"
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


    func icon() -> Image {
        switch self {
        case .soccer:
            return Image(systemName: "figure.soccer")
        case .running:
            return Image(systemName: "figure.run")
        case .walking:
            return Image(systemName: "figure.walk")
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

    func getName() -> String {
        switch self {
        case .soccer:
            return "Soccer"
        case .running:
            return "Running"
        case .walking:
            return "Walking"
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

    /// Stub - returns sport name string since HealthKit (HKWorkoutActivityType) is disabled
    func getWorkoutActivityType() -> String {
        return self.rawValue
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

/// Maps API string values (e.g. "GROUP", "ORGANIZATION") to GROUP_TYPE
func stringToGroupType(_ value: String) -> GROUP_TYPE {
    switch value.uppercased() {
    case "GROUP", "CLUB":
        return .Club
    case "ORGANIZATION":
        return .Organization
    default:
        return .Club
    }
}

enum EVENT_RSVP_STATUS: String, CaseIterable {
    case Yes = "yes"
    case Maybe = "maybe"
    case Waitlist = "waitlist"

    func toInt() -> Int {
        switch self {
        case .Yes:
            1
        case .Maybe:
            0
        case .Waitlist:
            2
        }
    }
}

func numberToEventRSVPStatus(_ number: Int) -> EVENT_RSVP_STATUS {
    if (number == 1) {
        return .Yes
    } else if (number == 0) {
        return .Maybe
    } else {
        return .Waitlist
    }
}

enum EVENT_VISIBILITY_TYPES: String, CaseIterable, Codable {
    case Public = "PUBLIC"
    case Group = "GROUP"
    case Private = "PRIVATE"
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

enum EVENT_TYPES: String, CaseIterable, Codable {
    case Regular = "REGULAR"
    case League = "LEAGUE"
    case Tournament = "TOURNAMENT"
    case Class = "CLASS"
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
enum WORKOUT_STATES {
    case pending
    case active
    case paused
    case ended
}

enum WORKOUT_TABS {
    case settings
    case metrics
    case advanced_metrics
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
    case normal = "normal"
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

enum MEDIA_TYPES: String {
    case image = "image"
    case video = "video"
}

// MARK: - Competition Formats
enum CompetitionFormats: String, Codable, CaseIterable {
    // General Team Sports (Soccer, Basketball, Volleyball, Football, Flag Football, Padel, Pickleball, Badminton, Ping-Pong, Racketball)
    case bracket = "bracket"                        // Knockout-style tournament
    case league = "league"                          // Regular season format
    case roundRobin = "round_robin"                 // Each team plays all other teams
    case singleElimination = "single_elimination"   // One loss and you're out
    case doubleElimination = "double_elimination"   // Two losses before elimination
    case bestOf3 = "best_of_3"                      // First to win 2 games
    case bestOf5 = "best_of_5"                      // First to win 3 games
    case winnerStaysOn = "winner_stays_on"          // Winners keep playing, losers rotate out

    // Team Formats (Soccer, Basketball, Volleyball, Football, Flag Football, Padel, Pickleball, Badminton, Ping-Pong, Racketball)
    case versus2 = "2v2"
    case versus3 = "3v3"
    case versus4 = "4v4"
    case versus5 = "5v5"
    case versus6 = "6v6"
    case versus7 = "7v7"
    case versus8 = "8v8"
    case versus9 = "9v9"
    case versus10 = "10v10"
    case versus11 = "11v11"

    // Individual Sports (Running, Cycling)
    case timeTrial = "time_trial"                   // Athletes race against the clock

    // Running
    case sprint = "sprint"                          // Short-distance race (e.g., 100m, 200m)
    case longDistance = "long_distance"             // Longer races (e.g., 5K, 10K, marathon)
    case relay = "relay"                            // Team race with baton passing

    // Cycling
    case roadRace = "road_race"                     // Mass-start long-distance race
    case criterium = "criterium"                    // Short circuit, multiple laps
    case stageRace = "stage_race"                   // Multi-day competition (e.g., Tour de France)

    // Golf
    case strokePlay = "stroke_play"                 // Total strokes over the round(s) determine the winner
    case matchPlay = "match_play"                   // Head-to-head format, winning holes instead of strokes
    case scramble = "scramble"                      // Teams play the best shot among their members
    case bestBall = "best_ball"                     // Each player plays their ball, best score counts for the team
    case stableford = "stableford"                  // Points awarded based on score per hole
    case skinsGame = "skins_game"                   // Each hole has a prize (skin), won outright by lowest score
    case alternateShot = "alternate_shot"           // Two-player teams alternate shots on the same ball
    case shamble = "shamble"                        // Similar to scramble but players play from the best tee shot
    case modifiedStableford = "modified_stableford" // Variation of Stableford with adjusted point values
    case scratch = "scratch"                        // No handicaps, raw stroke count matters

    // Climbing
    case bouldering = "bouldering"                  // Short, difficult climbing routes, no ropes
    case leadClimbing = "lead_climbing"             // Climbing as high as possible on a tall wall
    case speedClimbing = "speed_climbing"           // Race to the top
}

enum RSVPStatus: String, Codable {
    case going = "going"
    case notGoing = "not_going"
    case maybe = "maybe"
    case waitlist = "waitlist"
    case invited = "invited"
    case pending = "pending"
}

enum DevicePlatform: String, Codable {
    case ios = "ios"
    case watchOS = "watchOS"
    case android = "android"
    case web = "web"
}

/*
func sportFromActivityType(activity: HKWorkoutActivityType) -> SUPPORTED_SPORTS? {
    switch activity {
    case.americanFootball:
        return .football
    case .basketball:
        return .basketball
    case .climbing:
        return .climbing
    case .cycling:
        return .cycling
    case .golf:
        return .golf
    case .hiking:
        return .hiking
    case .racquetball:
        return .racquetball
    case .running:
        return .running
    case .soccer:
        return.soccer
    case .tennis:
        return .tennis
    case .volleyball:
        return .volleyball
    case .walking:
        return .walking
    case .pickleball:
        return .pickleball
    default:
        return nil
    }
}
*/

enum ACTIVITY_PAGES {
    case menu
    case metrics
    case details
}

enum ACTIVITY_GOALS: CaseIterable {
    case distance
    case duration
    case heart_rate
    case pace
    case zone

    func toString() -> String {
        switch self {
        case .distance:
            return "Distance"
        case .duration:
            return "Duration"
        case .heart_rate:
            return "Heart Rate"
        case .pace:
            return "Pace"
        case .zone:
            return "Zone"
        }
    }

    func toIcon() -> Image {
        switch self {
        case .distance:
            return Image(systemName: "road.lanes")
        case .duration:
            return Image(systemName: "clock")
        case .heart_rate:
            return Image(systemName: "heart")
        case .pace:
            return Image(systemName: "shoe")
        case .zone:
            return Image(systemName: "rectangle.grid.1x2")
        }
    }
}
