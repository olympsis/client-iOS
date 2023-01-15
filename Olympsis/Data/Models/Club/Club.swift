//
//  Club.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct Club: Codable, Identifiable {
    let id:             String
    var name:           String
    var description:    String?
    var sport:          String
    var city:           String
    var state:          String
    var country:        String
    var imageURL:       String?
    var isPrivate:      Bool?
    var members:        [Member]
    var rules:          [String]?
    var createdAt:      Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sport
        case city
        case state
        case country
        case imageURL
        case isPrivate
        case members
        case rules
        case createdAt
    }
}

struct Member: Codable, Identifiable {
    let id: String
    let uuid: String
    var role: String
    let data: UserPeek?
    let joinedAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case role
        case data
        case joinedAt
    }
}
