//
//  Participant.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/17/22.
//

import Foundation

struct Participant: Codable, Identifiable {
    let id: String
    let uuid: String
    let status: String
    let data: UserPeek
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case status
        case data
        case createdAt
    }
}
