//
//  FriendRequest.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import Foundation

struct FriendRequest: Decodable, Identifiable {
    let id: String
    let requestor: String
    let requestee: String
    let requestorData: UserPeek
    let status: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case requestor
        case requestee
        case requestorData
        case status
        case createdAt
    }
}

struct FriendRequests: Decodable {
    let totalRequests: Int
    let requests: [FriendRequest]
}
