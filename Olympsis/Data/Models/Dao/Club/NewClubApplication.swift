//
//  ClubApplication.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct NewClubApplication: Decodable {
    let id: String
    let uuid: String
    let clubId: String
    let status: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case clubId
        case status
        case createdAt
    }
}

