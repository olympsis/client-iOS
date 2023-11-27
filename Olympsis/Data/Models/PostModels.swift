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
    let poster: String
    let clubID: String?
    let body: String
    var eventID: String?
    let images: [String]?
    var data: PostData?
    var likes: [Like]?
    var comments: [Comment]?
    let createdAt: Int64?
    
    init(id: String?,
         type: String?,
         poster: String,
         clubID: String?,
         body: String,
         eventID: String?,
         images: [String]?,
         data: PostData?,
         likes: [Like]?,
         comments: [Comment]?,
         createdAt: Int64?) {
        
        self.id = id
        self.type = type
        self.poster = poster
        self.clubID = clubID
        self.body = body
        self.eventID = eventID
        self.images = images
        self.data = data
        self.likes = likes
        self.comments = comments
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poster
        case clubID = "club_id"
        case body
        case eventID = "event_id"
        case images
        case data
        case likes
        case comments
        case createdAt = "created_at"
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
    let user: UserData?
    let event: Event?
}

struct PostsResponse: Decodable {
    let totalPosts: Int
    let posts: [Post]
    
    enum CodingKeys: String, CodingKey {
        case totalPosts = "total_posts"
        case posts
    }
}
