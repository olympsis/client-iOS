//
//  NotificationModels.swift
//  Olympsis
//
//  Created by Joel on 11/15/23.
//

import Foundation
import NotificationCenter

/// Wire values MUST match `models.NotificationType` in the shared models repo
/// (`models/variables.go`) verbatim — that constant block is the source of
/// truth, and it's what both the inbox `type` field and the push `type` custom
/// field carry.
enum NotificationType: String, Codable, CaseIterable {
    case newClubApplication = "NEW_CLUB_APPLICATION"
    case clubApplicationUpdate = "CLUB_APPLICATION_UPDATE"
    case rankingChange = "RANKING_CHANGE"
    case suspension = "SUSPENSION"
    case expulsion = "EXPULSION"
    case memberReport = "MEMBER_REPORT"

    case postingApprovalRequest = "POSTING_APPROVAL_REQUEST"
    case postingApprovalRequestUpdate = "POSTING_APPROVAL_REQUEST_UPDATE"

    case newPost = "NEW_POST"
    case postReport = "POST_REPORT"
    case commentReport = "COMMENT_REPORT"

    case newEvent = "NEW_EVENT"
    case eventInvite = "EVENT_INVITE"
    case eventCoHost = "EVENT_CO_HOST"
    case eventComment = "EVENT_COMMENT"
    case eventParticipantUpdate = "EVENT_PARTICIPANT_UPDATE"
    case eventParticipantKick = "EVENT_PARTICIPANT_KICK"
    case eventParticipantWaitlistUpgrade = "EVENT_PARTICIPANT_WAITLIST_UPGRADE"
    case eventCancellation = "EVENT_CANCELLATION"
    case eventReminder = "EVENT_REMINDER"

    case teamInvite = "TEAM_INVITE"
    case teamApplication = "TEAM_APPLICATION"
    case teamApplicationUpdate = "TEAM_APPLICATION_UPDATE"
    case teamKick = "TEAM_KICK"
    case teamMemberRoleChange = "TEAM_MEMBER_ROLE_CHANGE"
    case teamDeleted = "TEAM_DELETED"

    case dailyEventSummary = "DAILY_EVENT_SUMMARY"
    case weeklyEventSummary = "WEEKLY_EVENT_SUMMARY"

    case newAnnouncement = "NEW_ANNOUNCEMENT"

    /// Server sent a type this build doesn't know about. Not a wire value —
    /// produced by the lenient initializer below so one new server type can't
    /// fail the decode of an entire notification list.
    case unknown = "UNKNOWN"

    /// Never fails: an unrecognized wire value becomes `.unknown` rather than
    /// throwing, so one new server-side type can't break the whole inbox decode.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = NotificationType(rawValue: raw) ?? .unknown
    }

    /// True for the types that render as an actionable invite card.
    var isInvite: Bool {
        switch self {
        case .eventInvite, .teamInvite, .eventCoHost:
            return true
        default:
            return false
        }
    }
}

extension NotificationType {
    /// Short headline, used when the server didn't send a `title`.
    ///
    /// Keys live in the `Notifications` string catalogue and are spelled out in
    /// full at each call site — a key built by interpolation would be extracted
    /// as a format string (`notification-title-%@`) and never resolve.
    var title: String {
        switch self {
        case .newClubApplication:
            return String(localized: "notification-title-new-club-application", table: "Notifications")
        case .clubApplicationUpdate:
            return String(localized: "notification-title-club-application-update", table: "Notifications")
        case .rankingChange:
            return String(localized: "notification-title-club-ranking-change", table: "Notifications")
        case .suspension:
            return String(localized: "notification-title-club-suspension", table: "Notifications")
        case .expulsion:
            return String(localized: "notification-title-club-expulsion", table: "Notifications")
        case .memberReport:
            return String(localized: "notification-title-member-report", table: "Notifications")
        case .postingApprovalRequest:
            return String(localized: "notification-title-post-approval-request", table: "Notifications")
        case .postingApprovalRequestUpdate:
            return String(localized: "notification-title-post-approval-request-update", table: "Notifications")
        case .newPost:
            return String(localized: "notification-title-new-post", table: "Notifications")
        case .postReport:
            return String(localized: "notification-title-post-report", table: "Notifications")
        case .commentReport:
            return String(localized: "notification-title-post-comment-report", table: "Notifications")
        case .newEvent:
            return String(localized: "notification-title-new-event", table: "Notifications")
        case .eventInvite:
            return String(localized: "notification-title-event-invite", table: "Notifications")
        case .eventCoHost:
            return String(localized: "notification-title-event-co-host", table: "Notifications")
        case .eventComment:
            return String(localized: "notification-title-event-comment", table: "Notifications")
        // Kick and waitlist-upgrade are both participant-status changes, so they
        // share that headline until they earn their own catalogue keys.
        case .eventParticipantUpdate, .eventParticipantKick, .eventParticipantWaitlistUpgrade:
            return String(localized: "notification-title-event-participant-update", table: "Notifications")
        case .eventReminder:
            return String(localized: "notification-title-event-reminder", table: "Notifications")
        case .teamInvite:
            return String(localized: "notification-title-team-invite", table: "Notifications")
        case .dailyEventSummary:
            return String(localized: "notification-title-daily-event-summary", table: "Notifications")
        case .weeklyEventSummary:
            return String(localized: "notification-title-weekly-event-summary", table: "Notifications")
        case .newAnnouncement:
            return String(localized: "notification-title-new-announcement", table: "Notifications")

        // TODO: these types exist server-side but have no catalogue key yet.
        // They fall back to the generic headline rather than rendering a raw key
        // string. Add `notification-title-{event-cancellation,team-application,
        // team-application-update,team-kick,team-member-role-change,team-deleted}`
        // to Notifications.xcstrings and split these out.
        case .eventCancellation,
             .teamApplication,
             .teamApplicationUpdate,
             .teamKick,
             .teamMemberRoleChange,
             .teamDeleted,
             .unknown:
            return String(localized: "notification-title-unknown", table: "Notifications")
        }
    }
}

// MARK: - Notification

/// One entry in the user's notification inbox.
///
/// Mirrors `inboxItem` in `notif-service/internal/service.go` exactly — that is
/// the only thing that serves this list, so this struct follows it rather than
/// the other way around. The server joins a `PushNotification` content record
/// with the recipient's read state; `id` is the *content* id, which is what a
/// PATCH marks read.
///
/// Note the server intentionally sends an empty `body`: bodies are localized
/// on-device from `data.locKey` + `data.locArgs`, the same way the notification
/// service extension localizes pushes. Use `localizedBody` rather than `body`.
struct NotificationModel: Decodable, Identifiable {
    var id: String
    var title: String
    var body: String
    var type: NotificationType
    var category: String
    var data: NotificationData
    var isRead: Bool
    var createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id, title, body, type, category, data
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    /// In-memory construction, for previews and synthesized rows. Declaring
    /// `init(from:)` suppresses the memberwise initializer, so it's spelled out.
    init(
        id: String,
        title: String = "",
        body: String = "",
        type: NotificationType,
        category: String = "",
        data: NotificationData = NotificationData(),
        isRead: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.category = category
        self.data = data
        self.isRead = isRead
        self.createdAt = createdAt
    }

    /// Every field except `id` and `type` is decoded leniently: the inbox is a
    /// heterogeneous list, and one row with a missing `category` or an
    /// unparseable date shouldn't cost the user the entire screen.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id       = try c.decode(String.self, forKey: .id)
        type     = try c.decode(NotificationType.self, forKey: .type)
        // `try?` on decodeIfPresent yields a double optional — flatten, then default.
        title    = ((try? c.decodeIfPresent(String.self, forKey: .title)) ?? nil) ?? ""
        body     = ((try? c.decodeIfPresent(String.self, forKey: .body)) ?? nil) ?? ""
        category = ((try? c.decodeIfPresent(String.self, forKey: .category)) ?? nil) ?? ""
        isRead   = ((try? c.decodeIfPresent(Bool.self, forKey: .isRead)) ?? nil) ?? false
        data     = ((try? c.decodeIfPresent(NotificationData.self, forKey: .data)) ?? nil) ?? NotificationData()

        if let date = try? c.decode(Date.self, forKey: .createdAt) {
            createdAt = date
        } else if let raw = try? c.decode(String.self, forKey: .createdAt) {
            createdAt = (try? parseDate(from: raw)) ?? Date()
        } else {
            createdAt = Date()
        }
    }

    /// What to show as the headline: the server's title when it sent one,
    /// otherwise the type's generic localized headline.
    var displayTitle: String {
        title.isEmpty ? type.title : title
    }

    /// The body, localized on-device from `loc_key` + `loc_args`.
    ///
    /// The server ships a key and arguments rather than a built string so the
    /// text renders in the reader's language. Falls back to the literal `body`
    /// when there's no key, or when the key isn't in this build's catalogue —
    /// which is the case for newer keys the app hasn't shipped strings for yet.
    var localizedBody: String {
        guard let key = data.locKey else { return body }

        // NSLocalizedString echoes the key when it's missing, so a sentinel
        // `value` is the only way to detect that. Mirrors the approach in
        // OlympsisNotificationService/NotificationService.swift.
        let missing = "\u{0}"
        let format = NSLocalizedString(key, tableName: "Notifications", bundle: .main, value: missing, comment: "")
        guard format != missing else { return body }

        let args = data.locArgs
        guard !args.isEmpty else { return format }

        // Numeric args go through as Int so %lld and plural rules resolve;
        // everything else as String for %@.
        let arguments: [CVarArg] = args.map { Int($0) ?? $0 as CVarArg }
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Notification data bag

/// The server's flat `data` map, with typed accessors for the keys we use.
///
/// `data` is `map[string]any` on the wire (built by `Note.auditData()` in
/// notif-service, which flattens the loc key/args and every routing id into one
/// level), so this decodes opportunistically: strings and string arrays are
/// kept, numbers and bools are stringified, anything else is skipped. Nothing
/// in here is required — an unknown or absent key just reads as nil.
struct NotificationData: Decodable {
    private var values: [String: String] = [:]
    private var lists: [String: [String]] = [:]

    init() {}

    init(_ values: [String: String] = [:], lists: [String: [String]] = [:]) {
        self.values = values
        self.lists = lists
    }

    /// Keys aren't known ahead of time, so decoding needs a dynamic key type.
    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: DynamicKey.self)
        for key in c.allKeys {
            if let s = try? c.decode(String.self, forKey: key) {
                values[key.stringValue] = s
            } else if let a = try? c.decode([String].self, forKey: key) {
                lists[key.stringValue] = a
            } else if let i = try? c.decode(Int.self, forKey: key) {
                values[key.stringValue] = String(i)
            } else if let d = try? c.decode(Double.self, forKey: key) {
                values[key.stringValue] = String(d)
            } else if let b = try? c.decode(Bool.self, forKey: key) {
                values[key.stringValue] = String(b)
            }
            // Nested objects and mixed arrays are dropped: nothing sends them,
            // and silently ignoring beats failing the row.
        }
    }

    /// Raw access for keys without a named accessor below.
    subscript(key: String) -> String? { values[key] }

    /// Raw access to a string-array value.
    func list(_ key: String) -> [String] { lists[key] ?? [] }

    // Localization
    var locKey: String? { values["loc_key"] }
    var locArgs: [String] { lists["loc_args"] ?? [] }

    /// The user who triggered this notification — the inviter, the commenter,
    /// the organizer who removed you. Absent (not empty) for system-triggered
    /// notes like reminders and waitlist promotions, so presence means "there is
    /// someone to show".
    var actorID: String? { values["actor_id"] }

    // Routing ids, as written by notif-service's per-type Note constructors.
    var inviteID: String? { values["invite_id"] }
    var eventID: String? { values["event_id"] }
    var teamID: String? { values["team_id"] }
    var clubID: String? { values["club_id"] }
    var postID: String? { values["post_id"] }
    var commentID: String? { values["comment_id"] }
    var participantID: String? { values["participant_id"] }

    var eventImageURL: String? { values["event_image_url"] }

    /// The thing this notification points at, for navigation, without having to
    /// know which routing key the type happens to use.
    var contextID: String? {
        eventID ?? teamID ?? clubID ?? postID
    }
}

struct NotificationUpdateRequest: Codable {
    var action: String
    var notificationIDs: [String]
    
    enum CodingKeys: String, CodingKey {
        case action
        case notificationIDs = "notification_ids"
    }
}

/// One page of the inbox. Mirrors `inboxResponse` in notif-service.
///
/// There is deliberately no unread count on the wire — the service's v1 doesn't
/// compute one, so callers derive it from the rows they have.
/// `nextCursor` is empty when there are no more pages.
struct NotificationItemListResponse: Decodable {
    var notifications: [NotificationModel]
    var nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case notifications
        case nextCursor = "next_cursor"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // Decode rows individually so one malformed entry drops itself rather
        // than emptying the whole inbox.
        var rows = [NotificationModel]()
        if var list = try? c.nestedUnkeyedContainer(forKey: .notifications) {
            while !list.isAtEnd {
                if let note = try? list.decode(NotificationModel.self) {
                    rows.append(note)
                } else {
                    _ = try? list.decode(AnyDecodableSkip.self)
                }
            }
        }
        notifications = rows
        nextCursor = try? c.decodeIfPresent(String.self, forKey: .nextCursor)
    }
}

/// Consumes and discards one element of an unkeyed container, so a failed decode
/// can advance past the bad entry instead of spinning on it.
private struct AnyDecodableSkip: Decodable {
    init(from decoder: Decoder) throws {}
}



struct AppNotification {
    let id = UUID()
    var type: NotificationType
    let title: String
    let body: String
    
    var clubID: String?
    var postID: String?
    var groupID: String?
    var eventID: String?
    let position: TOAST_POSITION
    
    init(type: NotificationType, title: String, body: String, clubID: String? = nil, postID: String? = nil, groupID: String? = nil, eventID: String? = nil) {
        self.type = type
        self.title = title
        self.body = body
        
        self.clubID = clubID
        self.postID = postID
        self.groupID = groupID
        self.eventID = eventID
        
        self.position = .top
    }
    
    init?(from notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        guard let _type = userInfo["type"] as? String,
              let noteType = NotificationType(rawValue: _type) else {
            return nil
        }
        
        self.type = noteType
        self.position = .top
        self.title = notification.request.content.title
        self.body = notification.request.content.body
        
        self.clubID = userInfo["club_id"] as? String
        self.postID = userInfo["post_id"] as? String
        self.eventID = userInfo["event_id"] as? String
    }
}

/// Lean payload for the three simplified event push notifications.
///
/// The server now sends only a `type` and the IDs needed to deep-link into
/// the event — the title/body are server-set and shown by the system
/// banner, so there's no rich data to render in-app. This intentionally
/// replaces the heavier `NotificationMetadata` for these notes; the rich
/// struct is still used by the other (club/post/message/report) toasts.
struct EventPushNote {

    /// The three lean event note types. Raw values match the matching
    /// `NotificationType` cases so they parse from the same `type` field.
    enum Kind: String {
        case participant = "EVENT_PARTICIPANT_UPDATE"
        case comment     = "EVENT_COMMENT"
        case reminder    = "EVENT_REMINDER"
    }

    let kind: Kind
    let eventID: String
    let participantID: String?
    let commentID: String?

    /// Parses a lean event note from a push payload. Returns `nil` when the
    /// note isn't one of the three lean event types or is missing its
    /// required `event_id`.
    init?(from notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        guard let rawType = userInfo["type"] as? String,
              let kind = Kind(rawValue: rawType),
              let eventID = userInfo["event_id"] as? String else {
            return nil
        }

        self.kind = kind
        self.eventID = eventID
        self.participantID = userInfo["participant_id"] as? String
        self.commentID = userInfo["comment_id"] as? String
    }
}

struct OlympsisNotification: Codable {
    var title: String
    var body: String
}

extension JSONDecoder {
    /// Handles RFC 3339 both with and without fractional seconds, which Go's
    /// `time.Time` marshaller emits inconsistently depending on the value.
    static var notifications: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
 
            let withFraction = ISO8601DateFormatter()
            withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = withFraction.date(from: raw) { return date }
 
            let plain = ISO8601DateFormatter()
            plain.formatOptions = [.withInternetDateTime]
            if let date = plain.date(from: raw) { return date }
 
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Unrecognized date format: \(raw)"
            )
        }
        return decoder
    }
}
