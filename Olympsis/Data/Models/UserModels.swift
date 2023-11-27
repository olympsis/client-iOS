//
//  UserModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/24/23.
//

import Foundation

struct User: Codable {
    let uuid: String?
    let username: String?
    let bio: String?
    let imageURL: String?
    let visibility: String?
    let clubs: [String]?
    var organizations: [String]?
    let sports: [String]?
    let deviceToken: String?

    init(uuid: String?=nil, username: String?=nil, bio: String?=nil, imageURL: String?=nil, visibility: String?=nil, clubs: [String]?=nil, organizations: [String]?=nil, sports: [String]?=nil, deviceToken: String? = nil) {
        self.uuid = uuid
        self.username = username
        self.bio = bio
        self.imageURL = imageURL
        self.visibility = visibility
        self.clubs = clubs
        self.organizations = organizations
        self.sports = sports
        self.deviceToken = deviceToken
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case bio
        case imageURL = "image_url"
        case visibility
        case clubs
        case organizations
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

struct UserData: Codable, Hashable {
    var uuid: String?
    var username: String?
    let firstName: String?
    let lastName: String?
    var imageURL: String?
    var visibility: String?
    var bio: String?
    var clubs: [String]?
    var organizations: [String]?
    var sports: [String]?
    var deviceToken: String?
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        guard let lhsID = lhs.uuid,
              let rhsID = rhs.uuid else {
            return false
        }
        return lhsID == rhsID
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case imageURL = "image_url"
        case visibility
        case bio
        case clubs
        case organizations
        case sports
        case deviceToken = "device_token"
    }
}
