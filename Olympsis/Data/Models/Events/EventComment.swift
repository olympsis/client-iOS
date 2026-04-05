//
//  Comment.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

class EventComment: Codable {
    var id: String
    var user: UserSnippet?
    var text: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case text
        case createdAt = "created_at"
    }
    
    init(id: String,
         user: UserSnippet? = nil,
         text: String,
         createdAt: Date) {
        self.id = id
        self.user = user
        self.text = text
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        text = try container.decode(String.self, forKey: .text)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = try parseDate(from: createdAtString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encode(text, forKey: .text)
        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
    }
}

class EventCommentDao: Codable {
    var id: String?
    var userID: String?
    var text: String?
    var eventID: String
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case text
        case eventID = "event_id"
        case createdAt = "created_at"
    }
    
    init(id: String? = nil,
         userID: String? = nil,
         text: String? = nil,
         eventID: String,
         createdAt: Date? = nil) {
        self.id = id
        self.userID = userID
        self.text = text
        self.eventID = eventID
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        eventID = try container.decode(String.self, forKey: .eventID)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(eventID, forKey: .eventID)
        try container.encodeIfPresent(createdAt?.ISO8601Format(), forKey: .createdAt)
    }
}



