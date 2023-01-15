//
//  ClubApplication.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import Foundation

struct ClubApplication: Decodable, Identifiable {
    let id: String
    let uuid: String
    let data: UserPeek
    let status: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case data
        case status
        case createdAt
    }
}
