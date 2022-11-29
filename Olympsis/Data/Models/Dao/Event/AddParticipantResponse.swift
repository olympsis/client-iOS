//
//  AddParticipantResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

struct AddParticipantResponse: Decodable {
    let id: String
    let uuid: String
    let status: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case status
        case createdAt
    }
}
