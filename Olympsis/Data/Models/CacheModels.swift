//
//  CacheModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/26/25.
//

import Foundation

struct UserCache: Codable {
    var uuid: String
    var username: String
    let firstName: String
    let lastName: String
    let gender: String?
    let birthdate: Date?
    var imageURL: String?
    var bio: String?
    var sports: [String]
    var visibility: String
    var acceptedEULA: Bool
    var hasOnboarded: Bool
    var blockedUsers: [String]
    var reportedPosts: [String]
    var reportedEvents: [String]
    var notificationDevices: [NotificationDevice]
    var notificationPreference: NotificationPreference?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case birthdate = "birthdate"
        case imageURL = "image_url"
        case bio
        case sports
        case visibility
        case acceptedEULA = "accepted_eula"
        case hasOnboarded = "has_onboarded"
        case blockedUsers = "blocked_users"
        case reportedPosts = "report_posts"
        case reportedEvents = "reported_events"
        case notificationDevices = "notification_devices"
        case notificationPreference = "notification_preference"
    }
}

//struct ClubCache: Codable {
//    var posts: [Post]
//    var members: [Member]
//}
//
//struct OrganizationCache: Codable {
//    var posts: [Post]
//    var members: [Member]
//}
