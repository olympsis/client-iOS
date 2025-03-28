//
//  NotificationModels.swift
//  Olympsis
//
//  Created by Joel on 11/15/23.
//

import Foundation

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
    var user: UserData?
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
