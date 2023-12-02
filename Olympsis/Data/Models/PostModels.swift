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
    let poster: String?
    let groupID: String?
    let body: String
    var eventID: String?
    let images: [String]?
    var data: PostData?
    var likes: [Like]?
    var comments: [Comment]?
    let createdAt: Int64?
    let externalLink: String?
    
    /// Complete initializer for the post class
    init(id: String?,
         type: String?,
         poster: String?,
         groupID: String?,
         body: String,
         eventID: String?,
         images: [String]?,
         data: PostData?,
         likes: [Like]?,
         comments: [Comment]?,
         createdAt: Int64?,
         externalLink: String?) {
        
        self.id = id
        self.type = type
        self.poster = poster
        self.groupID = groupID
        self.body = body
        self.eventID = eventID
        self.images = images
        self.data = data
        self.likes = likes
        self.comments = comments
        self.createdAt = createdAt
        self.externalLink = externalLink
    }
    
    /// Initalizer for creating posts client-side
    convenience init (type: String, groupID: String, body: String, eventID: String?, images: [String], externalLink: String?) {
        self.init(id: nil, type: type, poster: nil, groupID: groupID, body: body, eventID: eventID, images: images, data: nil, likes: nil, comments: nil, createdAt: nil, externalLink: externalLink)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poster
        case groupID = "group_id"
        case body
        case eventID = "event_id"
        case images
        case data
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

struct Comment: Codable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String?
    let uuid: String
    let text: String
    var data: UserData?
    let createdAt: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case text
        case data
        case createdAt = "created_at"
    }
}

struct PostData: Codable {
    let poster: UserData?
    let event: Event?
    let organization: Organization?
}

struct PostsResponse: Decodable {
    let totalPosts: Int
    let posts: [Post]
    
    enum CodingKeys: String, CodingKey {
        case totalPosts = "total_posts"
        case posts
    }
}
