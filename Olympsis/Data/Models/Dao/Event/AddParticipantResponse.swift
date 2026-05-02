//
//  AddParticipantResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

struct AddParticipantResponse: Decodable {
    let id: String
    let userID: String
    let status: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case status
        case createdAt
    }
}
