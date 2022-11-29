//
//  Post.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import Foundation

struct Post: Decodable, Identifiable {
    let id: String
    let owner: Owner
    let clubId: String
    let body: String
    let images: [String]?
    let likes: [String]?
    let comments: [Comment]?
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case owner
        case clubId
        case body
        case images
        case likes
        case comments
        case createdAt
    }
}

struct Owner: Decodable {
    let uuid: String
    let username: String
    let imageURL: String
}


