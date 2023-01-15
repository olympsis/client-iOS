//
//  User.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

/// User data object
struct UserDao: Codable {
    var uuid: String
    var username: String
    var bio: String?
    var imageURL: String?
    var isPublic: Bool
    var sports: [String]?
    var clubs: [String]?
    var badges: [Badge]?
    var trophies: [Trophy]?
    var friends: [Friend]?
    var deviceToken: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case bio
        case imageURL
        case isPublic
        case sports
        case clubs
        case badges
        case trophies
        case friends
        case deviceToken
    }
}
