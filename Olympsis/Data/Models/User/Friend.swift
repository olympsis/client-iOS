//
//  Friend.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/17/22.
//

import Foundation

/// Friend object for user data
struct Friend: Codable, Identifiable {
    let id: String
    let userID: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case createdAt
    }
}
