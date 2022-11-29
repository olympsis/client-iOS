//
//  NewPostResponseDoa.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import Foundation

struct NewPostResponseDao: Decodable {
    let id: String
    let owner: String
    let clubId: String
    let body: String
    let images: [String]?
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case owner
        case clubId
        case body
        case images
        case createdAt
    }
}
