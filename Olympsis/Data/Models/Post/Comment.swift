//
//  Comment.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

struct Comment: Decodable {
    let id: String
    let username: String
    let uuid: String
    let text: String
    let imageURL: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case uuid
        case text
        case imageURL
        case createdAt
    }
}
