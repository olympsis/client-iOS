//
//  ManagementModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/11/24.
//

import Foundation

struct BugReportDao: Codable {
    var id: String?
    var user: String?
    var notes: String?
    var status: String?
    var images: [String]?
    var videos: [String]?
    var blobs: [String]?
    var messages: [Message]?
    var createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case notes
        case status
        case images
        case videos
        case blobs
        case messages
        case createdAt = "created_at"
    }
}

struct FieldReportDao: Codable {
    var id: String?
    var user: String?
    var type: String?
    var fieldID: String?
    var notes: String?
    var status: String?
    var messages: [Message]?
    var createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case type
        case fieldID = "field_id"
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}

struct EventReportDao: Codable {
    var id: String?
    var user: String?
    var type: String?
    var eventID: String?
    var groups: [String]?
    var notes: String?
    var status: String?
    var messages: [Message]?
    var createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case type
        case eventID = "event_id"
        case groups
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}

struct EventReport: Decodable, Identifiable {
    var id: String
    var user: UserSnippet?
    var type: String
    var event: Event?
    var notes: String?
    var status: String
    var messages: [Message]?
    var createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case type
        case event
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}

struct PostReportDao: Codable {
    var id: String?
    var postID: String?
    var groupID: String?
    var type: String?
    var notes: String?
    var status: String?
    var messages: [Message]?
    var createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postID = "post_id"
        case groupID = "group_id"
        case type
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}

struct PostReport: Decodable, Identifiable {
    var id: String
    var post: Post?
    var type: String
    var notes: String?
    var status: String
    var messages: [Message]?
    var createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case post
        case type
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}

struct MemberReportDao: Codable {
    var id: String?
    var memberID: String?
    var groupID: String?
    var type: String?
    var notes: String?
    var status: String?
    var messages: [Message]?
    var createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case memberID = "member_id"
        case groupID = "group_id"
        case type
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}

struct MemberReport: Codable, Identifiable {
    var id: String
    var member: UserSnippet?
    var type: String
    var notes: String?
    var status: String
    var messages: [Message]?
    var createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case member
        case type
        case notes
        case status
        case messages
        case createdAt = "created_at"
    }
}
