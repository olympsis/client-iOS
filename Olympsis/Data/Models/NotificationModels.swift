//
//  NotificationModels.swift
//  Olympsis
//
//  Created by Joel on 11/15/23.
//

import Foundation
import NotificationCenter

enum NotificationType: String, Codable, CaseIterable {
    case clubInvite = "CLUB_INVITE"
    case newClubApplication = "NEW_CLUB_APPLICATION"
    case clubApplicationUpdate = "CLUB_APPLICATION_UPDATE"
    case clubRankingChange = "CLUB_RANKING_CHANGE"
    case clubSuspension = "CLUB_SUSPENSION"
    case clubExpulsion = "CLUB_EXPULSION"
    case memberReport = "MEMBER_REPORT"

    case postApprovalRequest = "POST_APPROVAL_REQUEST"
    case postApprovalRequestUpdate = "POST_APPROVAL_REQUEST_UPDATE"

    case newPost = "NEW_POST"
    case postLike = "POST_LIKE"
    case postComment = "POST_COMMENT"
    case postReport = "POST_REPORT"
    case postCommentReport = "POST_COMMENT_REPORT"

    case newEvent = "NEW_EVENT"
    case eventInvite = "EVENT_INVITE"
    case eventCoHost = "EVENT_CO_HOST"
    case eventComment = "EVENT_COMMENT"
    case eventParticipantUpdate = "EVENT_PARTICIPANT_UPDATE"
    case eventReminder = "EVENT_REMINDER"

    case teamInvite = "TEAM_INVITE"

    case dailyEventSummary = "DAILY_EVENT_SUMMARY"
    case weeklyEventSummary = "WEEKLY_EVENT_SUMMARY"

    case newAnnouncement = "NEW_ANNOUNCEMENT"

    case directMessage = "DIRECT_MESSAGE"
    case groupMessage = "GROUP_MESSAGE"
    case removedFromGroup = "REMOVED_FROM_GROUP"
    
    /// Server sent a type this build doesn't know about. Not a wire value —
    /// produced by the lenient initializer below so one new server type can't
    /// fail the decode of an entire notification list.
    case unknown = "UNKNOWN"
}

extension NotificationType {
    /// The one mapping from wire type to payload shape.
    ///
    /// Adding a case to `NotificationType` breaks this switch until you handle
    /// it — that compile error is the whole point. Don't add a `default:` here.
    var payloadKind: PayloadKind {
        switch self {
        case .clubInvite,
             .teamInvite,
             .eventInvite,
             .eventCoHost,
             .newClubApplication,
             .clubApplicationUpdate,
             .postApprovalRequest,
             .postApprovalRequestUpdate:
            return .invite
 
        case .newPost,
             .postLike,
             .postComment,
             .newEvent,
             .eventComment:
            return .engagement
 
        case .memberReport,
             .postReport,
             .postCommentReport:
            return .report
 
        case .directMessage,
             .groupMessage,
             .removedFromGroup:
            return .message
 
        case .dailyEventSummary,
             .weeklyEventSummary:
            return .digest
 
        case .clubRankingChange,
             .clubSuspension,
             .clubExpulsion,
             .eventParticipantUpdate:
            return .statusChange
 
        case .newAnnouncement,
             .eventReminder:
            return .simple
            
        case .unknown:
            return .unknown
        }
    }
    
    /// Short headline. Body text should come from the payload.
    ///
    /// Keys live in the `Notifications` string catalogue and are spelled out in
    /// full at each call site — a key built by interpolation would be extracted
    /// as a format string (`notification-title-%@`) and never resolve.
    var title: String {
        switch self {
        case .clubInvite:
            return String(localized: "notification-title-club-invite", table: "Notifications")
        case .newClubApplication:
            return String(localized: "notification-title-new-club-application", table: "Notifications")
        case .clubApplicationUpdate:
            return String(localized: "notification-title-club-application-update", table: "Notifications")
        case .clubRankingChange:
            return String(localized: "notification-title-club-ranking-change", table: "Notifications")
        case .clubSuspension:
            return String(localized: "notification-title-club-suspension", table: "Notifications")
        case .clubExpulsion:
            return String(localized: "notification-title-club-expulsion", table: "Notifications")
        case .memberReport:
            return String(localized: "notification-title-member-report", table: "Notifications")
        case .postApprovalRequest:
            return String(localized: "notification-title-post-approval-request", table: "Notifications")
        case .postApprovalRequestUpdate:
            return String(localized: "notification-title-post-approval-request-update", table: "Notifications")
        case .newPost:
            return String(localized: "notification-title-new-post", table: "Notifications")
        case .postLike:
            return String(localized: "notification-title-post-like", table: "Notifications")
        case .postComment:
            return String(localized: "notification-title-post-comment", table: "Notifications")
        case .postReport:
            return String(localized: "notification-title-post-report", table: "Notifications")
        case .postCommentReport:
            return String(localized: "notification-title-post-comment-report", table: "Notifications")
        case .newEvent:
            return String(localized: "notification-title-new-event", table: "Notifications")
        case .eventInvite:
            return String(localized: "notification-title-event-invite", table: "Notifications")
        case .eventCoHost:
            return String(localized: "notification-title-event-co-host", table: "Notifications")
        case .eventComment:
            return String(localized: "notification-title-event-comment", table: "Notifications")
        case .eventParticipantUpdate:
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
        case .directMessage:
            return String(localized: "notification-title-direct-message", table: "Notifications")
        case .groupMessage:
            return String(localized: "notification-title-group-message", table: "Notifications")
        case .removedFromGroup:
            return String(localized: "notification-title-removed-from-group", table: "Notifications")
        case .unknown:
            return String(localized: "notification-title-unknown", table: "Notifications")
        }
    }
}

// MARK: - Payload shape
 
/// The *structure* of a payload, independent of which type produced it.
enum PayloadKind {
    case invite
    case engagement
    case report
    case message
    case digest
    case statusChange
    case simple
    case unknown
}

struct NotificationModel: Decodable, Identifiable {
    var id: String
    var type: NotificationType
    var payload: Payload
    
    var readAt: Date?
    var createdAt: Date
    var archivedAt: Date?
    
    var isRead: Bool { readAt != nil }
    var isArchived: Bool { archivedAt != nil }
    
    private enum CodingKeys: String, CodingKey {
        case id, type, payload
        case readAt = "read_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case archivedAt = "archived_at"
    }
    
    /// Builds a note in memory rather than from the wire.
    ///
    /// Declaring `init(from:)` inside the struct suppresses the compiler's
    /// memberwise initializer, so it's re-declared here in an extension for
    /// previews and locally synthesized notes.
    init(
        id: String,
        type: NotificationType,
        payload: Payload,
        readAt: Date? = nil,
        createdAt: Date,
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.payload = payload
        self.readAt = readAt
        self.createdAt = createdAt
        self.archivedAt = archivedAt
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id         = try c.decode(String.self, forKey: .id)
        type       = try c.decode(NotificationType.self, forKey: .type)
        readAt     = try c.decodeIfPresent(Date.self, forKey: .readAt)
        createdAt  = try c.decode(Date.self, forKey: .createdAt)
        archivedAt = try c.decodeIfPresent(Date.self, forKey: .archivedAt)

        // Tolerate a missing or null payload rather than failing the row.
        guard c.contains(.payload), try !c.decodeNil(forKey: .payload) else {
            payload = .unknown
            return
        }
 
        switch type.payloadKind {
        case .invite:
            payload = .invite(try c.decode(Payload.Invite.self, forKey: .payload))
            readAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt)
        case .engagement:
            payload = .engagement(try c.decode(Payload.Engagement.self, forKey: .payload))
        case .report:
            payload = .report(try c.decode(Payload.Report.self, forKey: .payload))
        case .message:
            payload = .message(try c.decode(Payload.Message.self, forKey: .payload))
        case .digest:
            payload = .digest(try c.decode(Payload.Digest.self, forKey: .payload))
        case .statusChange:
            payload = .statusChange(try c.decode(Payload.StatusChange.self, forKey: .payload))
        case .simple:
            payload = .simple(try c.decode(Payload.Simple.self, forKey: .payload))
        case .unknown:
            payload = .unknown
        }
    }
}

// MARK: - Payload
extension NotificationModel {
    enum Payload {
        case invite(Invite)
        case engagement(Engagement)
        case report(Report)
        case message(Message)
        case digest(Digest)
        case statusChange(StatusChange)
        case simple(Simple)
        case unknown
 
        // MARK: Shapes
 
        /// Someone is asking the recipient to join / approve something.
        struct Invite: Decodable {
            let contextID: String
            let requestorID: String
            let status: InviteStatus
 
            private enum CodingKeys: String, CodingKey {
                case contextID = "context_id"
                case requestorID = "requestor_id"
                case status
            }
        }
 
        /// Someone acted on the recipient's content, or new content appeared.
        struct Engagement: Decodable {  // TODO: verify against backend
            let contextID: String
            let actorID: String
            let actorName: String?
            let preview: String?
            /// e.g. "and 4 others" — server-aggregated count, if you aggregate.
            let count: Int?
 
            private enum CodingKeys: String, CodingKey {
                case contextID = "context_id"
                case actorID = "actor_id"
                case actorName = "actor_name"
                case preview
                case count
            }
        }
 
        /// Moderation: content or a member was reported.
        struct Report: Decodable {  // TODO: verify against backend
            let contextID: String
            let reportID: String
            let reporterID: String
            let reason: String?
 
            private enum CodingKeys: String, CodingKey {
                case contextID = "context_id"
                case reportID = "report_id"
                case reporterID = "reporter_id"
                case reason
            }
        }
 
        /// Direct / group messaging.
        struct Message: Decodable {  // TODO: verify against backend
            let conversationID: String
            let senderID: String?
            let senderName: String?
            let preview: String?
 
            private enum CodingKeys: String, CodingKey {
                case conversationID = "conversation_id"
                case senderID = "sender_id"
                case senderName = "sender_name"
                case preview
            }
        }
 
        /// Periodic roll-up.
        struct Digest: Decodable {  // TODO: verify against backend
            let periodStart: Date
            let periodEnd: Date
            let eventCount: Int
            let eventIDs: [String]
 
            private enum CodingKeys: String, CodingKey {
                case periodStart = "period_start"
                case periodEnd = "period_end"
                case eventCount = "event_count"
                case eventIDs = "event_ids"
            }
        }
 
        /// Something the recipient belongs to changed state.
        struct StatusChange: Decodable {  // TODO: verify against backend
            let contextID: String
            let previousValue: String?
            let newValue: String?
            let reason: String?
 
            private enum CodingKeys: String, CodingKey {
                case contextID = "context_id"
                case previousValue = "previous_value"
                case newValue = "new_value"
                case reason
            }
        }
 
        /// Server-authored text with somewhere to navigate.
        struct Simple: Decodable {  // TODO: verify against backend
            let contextID: String?
            let title: String?
            let body: String?
 
            private enum CodingKeys: String, CodingKey {
                case contextID = "context_id"
                case title, body
            }
        }
    }
}

// MARK: - Payload conveniences
 
extension NotificationModel.Payload {
    /// The thing this notification points at, when there is one.
    /// Use for navigation without switching on every shape.
    var contextID: String? {
        switch self {
        case .invite(let p):       return p.contextID
        case .engagement(let p):   return p.contextID
        case .report(let p):       return p.contextID
        case .message(let p):      return p.conversationID
        case .statusChange(let p): return p.contextID
        case .simple(let p):       return p.contextID
        case .digest, .unknown:    return nil
        }
    }
 
    /// Whoever caused the notification, when there is a single person.
    var actorID: String? {
        switch self {
        case .invite(let p):     return p.requestorID
        case .engagement(let p): return p.actorID
        case .report(let p):     return p.reporterID
        case .message(let p):    return p.senderID
        case .digest, .statusChange, .simple, .unknown: return nil
        }
    }
 
    /// Non-nil only for invite-shaped payloads, so action buttons can be
    /// driven off `if let status = payload.inviteStatus`.
    var inviteStatus: InviteStatus? {
        guard case .invite(let p) = self else { return nil }
        return p.status
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

struct NotificationItemListResponse: Decodable {
    var unreadCount: Int
    var totalNotifications: Int
    var notifications: [NotificationModel]
    
    enum CodingKeys: String, CodingKey {
        case unreadCount = "unread_count"
        case totalNotifications = "total_notifications"
        case notifications
    }
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
