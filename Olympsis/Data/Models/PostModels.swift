//
//  PostModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

import SwiftUI
import Foundation

class Post: Identifiable, RandomAccessCollection, Equatable, ObservableObject, Decodable {
    
    let id: String
    let type: String
    let poster: UserSnippet?
    let body: String
    var event: Event?
    let images: [String]?
    @Published var likes: [Reaction]
    @Published var comments: [Comment]
    let externalLink: String?
    @Published var isSensitive: Bool
    let createdAt: Date
    
    /// Complete initializer for the post class
    init(id: String,
         type: String,
         poster: UserSnippet?,
         body: String,
         event: Event? = nil,
         images: [String]?,
         likes: [Reaction] = [],
         comments: [Comment] = [],
         externalLink: String?,
         isSensitive: Bool = false,
         createdAt: Date) {
        
        self.id = id
        self.type = type
        self.poster = poster
        self.body = body
        self.event = event
        self.images = images
        self.likes = likes
        self.comments = comments
        self.externalLink = externalLink
        self.isSensitive = isSensitive
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poster
        case body
        case event
        case images
        case likes
        case comments
        case externalLink = "external_link"
        case isSensitive = "is_sensitive"
        case createdAt = "created_at"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        poster = try container.decodeIfPresent(UserSnippet.self, forKey: .poster)
        body = try container.decode(String.self, forKey: .body)
        event = try container.decodeIfPresent(Event.self, forKey: .event)
        images = try container.decodeIfPresent([String].self, forKey: .images)
        likes = try container.decodeIfPresent([Reaction].self, forKey: .likes) ?? [Reaction]()
        comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? [Comment]()
        externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = try parseDate(from: createdAtString)
        
        isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
    }

    
    // RandomAccessCollection requirements
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return 1
    }
    
    subscript(index: Int) -> Post {
        return self
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PostsResponse: Decodable {
    let totalPosts: Int
    let posts: [Post]
    
    enum CodingKeys: String, CodingKey {
        case totalPosts = "total_posts"
        case posts
    }
}

struct PostDTO: Codable {
    var type: String?
    var poster: String?
    var groupID: String?
    var body: String?
    var eventID: String?
    var images: [String]?
    var isSensitive: Bool
    var externalLink: String?
    var createdAt: Date?
    
    init(type: String? = nil, poster: String? = nil, groupID: String? = nil, body: String? = nil, eventID: String? = nil, images: [String]? = nil, isSensitive: Bool = false, externalLink: String? = nil, createdAt: Date? = nil) {
        self.type = type
        self.poster = poster
        self.groupID = groupID
        self.body = body
        self.eventID = eventID
        self.images = images
        self.isSensitive = isSensitive
        self.externalLink = externalLink
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case poster
        case groupID = "group_id"
        case body
        case eventID = "event_id"
        case images
        case isSensitive = "is_sensitive"
        case externalLink = "external_link"
        case createdAt = "created_at"
    }
}
