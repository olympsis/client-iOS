//
//  UserPeek.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import Foundation

struct UserPeek: Decodable {
    let firstName: String
    let lastName: String
    let username: String
    let imageURL: String
    let sports: [String]
    let badges: [Badge]
    let trophies: [Trophy]
    let friends: [Friend]
}
