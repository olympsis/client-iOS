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
    let uuid: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case createdAt
    }
}
