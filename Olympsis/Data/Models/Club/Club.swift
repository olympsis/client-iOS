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
    var description:    String
    var sport:          String
    var city:           String
    var state:          String
    var country:        String
    var imageURL:       String
    var isPrivate:      Bool
    var isVisible:      Bool
    var members:        [Member]
    var rules:          [String]
    var createdAt:      Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case sport
        case city
        case state
        case country
        case imageURL
        case isPrivate
        case isVisible
        case members
        case rules
        case createdAt
    }
}

struct Member: Codable {
    let id: String?
    let uuid: String
    let role: String
    let joinedAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case role
        case joinedAt
    }
}
