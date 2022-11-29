//
//  Trophy.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

/// Trophy object for user data.
struct Trophy: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let imageURL: String
    let tournamentId: String
    let description: String
    let achievedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case title
        case imageURL
        case tournamentId
        case description
        case achievedAt
    }
    
}
