//
//  PostModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

import SwiftUI
import Foundation

class Post: Codable, Identifiable, RandomAccessCollection, Equatable {
    
    let id: String?
    let type: String?
    let poster: UserSnippet?
    let body: String
    var event: Event?
    let images: [String]?
    var likes: [Like]?
    var comments: [Comment]?
    let createdAt: Int?
    let externalLink: String?
    
    /// Complete initializer for the post class
    init(id: String?,
         type: String?,
         poster: UserSnippet?,
         body: String,
         event: Event?=nil,
         images: [String]?,
         likes: [Like]?,
         comments: [Comment]?,
         createdAt: Int?,
         externalLink: String?) {
        
        self.id = id
        self.type = type
        self.poster = poster
        self.body = body
        self.event = event
        self.images = images
        self.likes = likes
        self.comments = comments
        self.createdAt = createdAt
        self.externalLink = externalLink
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
        case createdAt = "created_at"
        case externalLink = "external_link"
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

struct PostDao: Codable {
    var type: String?
    var poster: String?
    var groupID: String?
    var body: String?
    var eventID: String?
    var images: [String]?
    var createdAt: Int64?
    var externalLink: String?
    
    init(type: String? = nil, poster: String? = nil, groupID: String? = nil, body: String? = nil, eventID: String? = nil, images: [String]? = nil, createdAt: Int64? = nil, externalLink: String? = nil) {
        self.type = type
        self.poster = poster
        self.groupID = groupID
        self.body = body
        self.eventID = eventID
        self.images = images
        self.createdAt = createdAt
        self.externalLink = externalLink
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case poster
        case groupID = "group_id"
        case body
        case eventID = "event_id"
        case images
        case createdAt = "created_at"
        case externalLink = "external_link"
    }
}
