//
//  DevData.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import Foundation

struct DevData: Decodable {
    let users:  [UserDao]
    let fields: [Field]
    let clubs:  [Club]
    let events: [Event]
    let posts:  [Post]
    
    enum CodingKeys: String, CodingKey {
        case users = "users"
        case fields = "fields"
        case clubs = "clubs"
        case events = "events"
        case posts = "posts"
    }
}
