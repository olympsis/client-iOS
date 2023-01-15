//
//  UserStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/23/22.
//

import Foundation

/// User data object to cache user data
struct UserStore: Codable {
    
    // Personal Info
    var firstName:  String
    var lastName:   String
    var email:      String
    var uuid:       String
    
    // Personal Data
    var username: String
    var bio: String?
    var imageURL: String?
    var isPublic: Bool
    var sports: [String]?
    var clubs: [String]?
    var badges: [Badge]?
    var trophies: [Trophy]?
    var friends: [Friend]?
}
