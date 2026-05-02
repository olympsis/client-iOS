//
//  ClubApplication.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct NewClubApplication: Decodable {
    let id: String
    let userID: String
    let clubId: String
    let status: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userID = "user_id"
        case clubId
        case status
        case createdAt
    }
}

