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

/// A launch-critical call (the system config, or check-in) failed for a reason
/// the user can act on, so the app shows a page about it instead of continuing.
///
/// This is deliberately separate from `AUTH_STATUS.fatal_error`: an outage is
/// retryable and says something specific, while a fatal error is the dead end we
/// can't explain. Nothing persists it — a relaunch should try again.
enum LAUNCH_OUTAGE: String {
    /// The device has no usable network.
    case offline
    /// The network is fine; Olympsis isn't answering (5xx, or nothing listening).
    case serverDown
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

/// Raw values are the recurrence patterns the server accepts. `allCases` drives
/// the picker, so the declaration order here is the order shown on screen.
enum EVENT_RECURRENCE_FREQUENCY: String, CaseIterable {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"

    /// Localized label for the frequency button.
    func displayName() -> String {
        switch self {
        case .daily:
            return String(localized: "advanced-settings-recurrence-frequency-daily", defaultValue: "Daily", table: "Events")
        case .weekly:
            return String(localized: "advanced-settings-recurrence-frequency-weekly", defaultValue: "Weekly", table: "Events")
        case .monthly:
            return String(localized: "advanced-settings-recurrence-frequency-monthly", defaultValue: "Monthly", table: "Events")
        }
    }
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

/// Where to scroll/focus inside an event detail view when it is opened
/// from a deep link or a tapped push notification. Carried through the
/// routing chain (`ROUTES` → `EVENT_ROUTES` → `EventView`).
enum EventFocus: Codable, Hashable {
    /// Scroll to the participants section (e.g. a "New Participant" note).
    case participants
    /// Scroll to a specific comment (e.g. a "New Comment" note).
    case comment(id: String)
}

enum ROUTES: Codable, Hashable {
    case home(
        postId: String?=nil,
        openMessages: Bool?=nil,
        openNotifications: Bool?=nil
    )
    case groups(id: String?=nil)
    case events(id: String?=nil, venueId: String?=nil, focus: EventFocus?=nil)
    case profile
}

enum HOME_ROUTES: Codable, Hashable {
    case notifications
    case archivedNotifications
    case messages
    case full_post_view(_ postId: String)
    case upNextEvents(_ events: [Event])
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
        openEvents: Bool?=nil,
        focus: EventFocus?=nil
    )
    case event(event: Event)
    case upNextEvents(events: [Event])
    case venue(venue: Venue)
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
            return Image("logo/spikeball")
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

    /// The value the API expects for an organizer's `type`. The raw values above
    /// are the app's own vocabulary ("club"), while the server speaks "GROUP" —
    /// `stringToGroupType` is the inverse of this.
    var apiValue: String {
        switch self {
        case .Club:
            return "GROUP"
        case .Organization:
            return "ORGANIZATION"
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
    case Cant = "cant"

    func toInt() -> Int {
        switch self {
        case .Yes:
            1
        case .Maybe:
            0
        case .Waitlist:
            2
        case .Cant:
            3
        }
    }

    /// The equivalent invite-service RSVP value, for `UpdateInviteRequest.response`.
    ///
    /// The two enums exist because they belong to different services: this one is
    /// the events API's, `RSVPStatus` is invite-service's. The invite endpoint
    /// now honors `response` — it becomes the status of the participant row the
    /// server writes when the invite is accepted (omitted means YES). Registering
    /// the RSVP up front is still a separate call to the events API; sending it
    /// here is what stops the acceptance from overwriting it with YES.
    var asRSVPStatus: RSVPStatus {
        switch self {
        case .Yes:
            return .yes
        case .Maybe:
            return .maybe
        case .Waitlist:
            return .waitlist
        case .Cant:
            return .cant
        }
    }
}

/// Maps the server's legacy integer status (0=MAYBE, 1=YES, 2=WAITLIST, 3=CAN'T)
/// to the enum. Written as a total switch so an unexpected value falls back to
/// `.Maybe` instead of being silently misclassified.
func numberToEventRSVPStatus(_ number: Int) -> EVENT_RSVP_STATUS {
    switch number {
    case 0:
        return .Maybe
    case 1:
        return .Yes
    case 2:
        return .Waitlist
    case 3:
        return .Cant
    default:
        return .Maybe
    }
}

// Accepts the server's string form ("YES", "CAN'T", ...) in any case and maps
// it to a status. The apostrophe in "CAN'T" is stripped so it matches the
// "cant" raw value. Unknown values fall back to .Maybe so a new server value
// can't break decoding.
func stringToEventRSVPStatus(_ raw: String) -> EVENT_RSVP_STATUS {
    let normalized = raw.trimmingCharacters(in: .whitespaces).uppercased().replacingOccurrences(of: "'", with: "")
    switch normalized {
    case "YES": return .Yes
    case "MAYBE": return .Maybe
    case "WAITLIST": return .Waitlist
    case "CANT": return .Cant
    default: return .Maybe
    }
}

enum EVENT_VISIBILITY_TYPES: String, CaseIterable, Codable {
    case Public = "PUBLIC"
    case Group = "GROUP"
    case Private = "PRIVATE"

    /// SF Symbol shown beside the visibility name in the picker. Uses the filled variants.
    func image() -> Image {
        switch self {
        case .Public:
            return .init(systemName: "sun.max.fill")
        case .Private:
            return .init(systemName: "moon.fill")
        case .Group:
            return .init(systemName: "person.3.fill")
        }
    }

    /// Localized display name for the visibility option.
    func name() -> String {
        switch self {
        case .Public:
            return String(localized: "visibility-public", table: "Events")
        case .Private:
            return String(localized: "visibility-private", table: "Events")
        case .Group:
            return String(localized: "visibility-group", table: "Events")
        }
    }

    /// Localized explanation of what the visibility option means.
    func description() -> String {
        switch self {
        case .Public:
            return String(localized: "visibility-public-details", table: "Events")
        case .Private:
            return String(localized: "visibility-private-details", table: "Events")
        case .Group:
            return String(localized: "visibility-group-details", table: "Events")
        }
    }

    /// Optional supporting tip shown beneath the description in the visibility picker.
    func tip() -> String? {
        switch self {
        case .Public:
            return String(localized: "visibility-public-tip", table: "Events")
        case .Private:
            return String(localized: "visibility-private-tip", table: "Events")
        case .Group:
            return String(localized: "visibility-group-tip", table: "Events")
        }
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
    case badRecurrence
}

enum SkillLevel: String, CaseIterable {
    case any = "Any Level"
    case beginner   = "Beginner"
    case amateur    = "Amateur"
    case expert     = "Expert"
}

/// Raw values are the server's `type` strings. Never show `rawValue` in the UI —
/// use `displayName()`, which is localized.
enum EVENT_TYPES: String, CaseIterable, Codable {
    case Regular = "REGULAR"
    case Class = "CLASS"
    case Match = "MATCH"
    case League = "LEAGUE"
    case Tournament = "TOURNAMENT"

    /// Localized display name for the type, shown in the picker and on the
    /// new-event type button.
    func displayName() -> String {
        switch self {
        case .Regular:
            return String(localized: "event-type-regular", defaultValue: "Regular", table: "Events")
        case .Class:
            return String(localized: "event-type-class", defaultValue: "Class", table: "Events")
        case .Match:
            return String(localized: "event-type-match", defaultValue: "Match", table: "Events")
        case .League:
            return String(localized: "event-type-league", defaultValue: "League", table: "Events")
        case .Tournament:
            return String(localized: "event-type-tournament", defaultValue: "Tournament", table: "Events")
        }
    }

    func image() -> Image {
        switch self {
        case .Regular:
            return .init(systemName: "sun.min.fill")
        case .Class:
            return .init(systemName: "book.closed.fill")
        case .Match:
            return .init(systemName: "calendar.day.timeline.left")
        case .League:
            return .init(systemName: "person.3.fill")
        case .Tournament:
            return .init(systemName: "trophy.fill")
        }
    }
    
    func description() -> String {
        switch self {
        case .Regular:
            return String(localized: "event-type-regular-desc", table: "Events")
        case .Class:
            return String(localized: "event-type-class-desc", table: "Events")
        case .Match:
            return String(localized: "event-type-match-desc", table: "Events")
        case .League:
            return String(localized: "event-type-league-desc", table: "Events")
        case .Tournament:
            return String(localized: "event-type-tournament-desc", table: "Events")
        }
    }

    /// Optional supporting tip shown beneath the description in the type picker.
    /// `Regular` has no tip; the others map to `event-type-<type>-tip` keys in `Events.xcstrings`.
    func tip() -> String? {
        switch self {
        case .Regular:
            return nil
        case .Class:
            return String(localized: "event-type-class-tip", table: "Events")
        case .Match:
            return String(localized: "event-type-match-tip", table: "Events")
        case .League:
            return String(localized: "event-type-league-tip", table: "Events")
        case .Tournament:
            return String(localized: "event-type-tournament-tip", table: "Events")
        }
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

/// Raw values are the server's `media_type` strings. Decode sites uppercase the
/// incoming value first, so events cached by older builds (lowercase) still read.
enum MEDIA_TYPES: String {
    case image = "IMAGE"
    case video = "VIDEO"
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

/// invite-service's RSVP vocabulary, used only for `UpdateInviteRequest.response`.
///
/// The raw values are exactly the strings the server's `models.RSVPStatus`
/// parses — including the apostrophe in `CAN'T`. Anything else is rejected with
/// a 400, so don't "tidy" these; map from `EVENT_RSVP_STATUS.asRSVPStatus`
/// instead of writing values by hand.
enum RSVPStatus: String, Codable {
    case yes = "YES"
    case maybe = "MAYBE"
    case cant = "CAN'T"
    case waitlist = "WAITLIST"
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

enum EVENT_EXPLORER_STATE: String, Codable, CaseIterable {
    var id: Self { self }

    case events = "events"
    case venues = "venues"

    /// Localized label for this page, used by the explorer picker.
    /// Keys live in `Events.xcstrings` as `event-explorer-state-events` / `event-explorer-state-venues`.
    var localized: String {
        switch self {
        case .events:
            return String(localized: "event-explorer-state-events", table: "Events")
        case .venues:
            return String(localized: "event-explorer-state-venues", table: "Events")
        }
    }
}

enum LIST_ITEM_SCALE {
    case small
    case regular
}

enum TRANSIT_SCALE {
    case small
    case regular
}

// MARK: - Invites

/// The kind of resource an invite is for. Raw values match the server's
/// `InviteType` constants exactly.
enum InviteType: String, Codable, CaseIterable {
    case event = "EVENT"
    case team = "TEAM"
    case club = "CLUB"
    case org = "ORG"
}

/// Where an invite stands in its lifecycle. Raw values match the server's
/// `InviteStatus` constants exactly.
enum InviteStatus: String, Codable, CaseIterable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
}
