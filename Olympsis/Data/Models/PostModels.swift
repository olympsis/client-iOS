//
//  PostModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

import Foundation

struct Post: Codable, Identifiable {
    let id: String?
    let poster: String
    let clubID: String?
    let body: String
    var eventID: String?
    let images: [String]?
    let data: PostData?
    var likes: [Like]?
    var comments: [Comment]?
    let createdAt: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
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
}

struct Comment: Codable {
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
