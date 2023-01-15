//
//  Like.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/17/22.
//

import Foundation

struct Like: Codable {
    let id: String
    let uuid: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case createdAt
    }
}
