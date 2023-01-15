//
//  UserPeek.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import Foundation

struct UserPeek: Codable {
    let firstName: String
    let lastName: String
    let username: String
    let imageURL: String?
    let bio: String?
    let sports: [String]?
    let badges: [Badge]?
    let trophies: [Trophy]?
    let friends: [Friend]?
    
    init(firstName: String, lastName: String, username: String, imageURL: String?, bio: String?, sports: [String], badges:[Badge]?=nil, trophies:[Trophy]?=nil, friends:[Friend]?=nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.imageURL = imageURL
        self.bio = bio
        self.sports = sports
        self.badges = badges
        self.trophies = trophies
        self.friends = friends
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case username
        case imageURL
        case bio
        case sports
        case badges
        case trophies
        case friends
    }
}
