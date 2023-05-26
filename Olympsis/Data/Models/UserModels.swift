//
//  UserModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/24/23.
//

import Foundation

struct User: Codable {
    let id: String?=""
    let uuid: String?=""
    let username: String
    let bio: String?=""
    let imageUrl: String?=""
    let visibility: String
    let clubs: [String]?=[String]()
    let sports: [String]
    let deviceToken: String?=""
        
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case username
        case bio
        case imageUrl = "image_url"
        case visibility
        case clubs
        case sports
        case deviceToken = "device_token"
    }
}

struct UsernameAvailabilityResponse: Codable {
    var isAvailable: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isAvailable = "is_available"
    }
}
