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
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case createdAt
    }
}
