//
//  Comment.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

struct Comment: Decodable {
    let id: String
    let uuid: String
    let text: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case text
        case createdAt
    }
}
