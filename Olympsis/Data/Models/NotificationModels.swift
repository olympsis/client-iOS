//
//  NotificationModels.swift
//  Olympsis
//
//  Created by Joel on 11/15/23.
//

import Foundation
import NotificationCenter

struct OlympsisNotification: Codable {
    var title: String
    var body: String
}

struct NotificationModel: Decodable {
    var id: String
    var type: String
    var club: Club?
    var event: Event?
    var organization: Organization?
    var invite: Invitation?
    var user: User?
    var body: String
}

struct NotificationItem: Decodable {
    var id: String
    var title: String
    var body: String
    var type: String
    var category: String
//    var data: [String: Any]
    var isRead: Bool
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case type
        case category
//        case data
        case isRead = "is_read"
        case createdAt = "created_at"
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
    var notifications: [NotificationItem]
    
    enum CodingKeys: String, CodingKey {
        case unreadCount = "unread_count"
        case totalNotifications = "total_notifications"
        case notifications
    }
}

enum NotificationType: String, CaseIterable {
    case newClubApplication = "new_club_application"
    case clubApplicationUpdate = "club_application_update"
    case clubRankingChange = "club_ranking_change"
    case clubSuspension = "club_suspension"
    case clubExpulsion = "club_expulsion"
    case memberReport = "member_report"
    
    case postApprovalRequest = "post_approval_request"
    case postApprovalRequestUpdate = "post_approval_request_update"
    
    case newPost = "new_post"
    case postLike = "post_like"
    case postComment = "post_comment"
    case postReport = "post_report"
    case postCommentReport = "post_comment_report"
    
    case newEvent = "new_event"
    case eventComment = "event_comment"
    case eventParticipantUpdate = "event_participant_update"
    case eventReminder = "event_reminder"
    
    case dailyEventSummary = "daily_event_summary"
    case weeklyEventSummary = "weekly_event_summary"
    
    case newAnnouncement = "new_announcement"
    
    case directMessage = "direct_message"
    case groupMessage = "group_message"
    case removedFromGroup = "removed_from_group"
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
        case participant = "event_participant_update"
        case comment     = "event_comment"
        case reminder    = "event_reminder"
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
