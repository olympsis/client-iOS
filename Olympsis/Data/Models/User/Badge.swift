//
//  Badge.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

/// Badge object for user data. 
struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let imageURL: String
    let eventId: String
    let description: String
    let achievedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case title
        case imageURL
        case eventId
        case description
        case achievedAt
    }
}
