//
//  UserDataResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

class UserDataResponse: Codable {
    let userID: String
    let userName: String
    let imageURL: String
    let clubs: [String]?
    let sports: [String]
    let badges: [Badge]?
    let trophies: [Trophy]?
    let friends: [String]?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case userName
        case imageURL
        case clubs
        case sports
        case badges
        case trophies
        case friends
    }
}
