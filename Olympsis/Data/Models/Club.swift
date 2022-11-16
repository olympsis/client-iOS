//
//  Club.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct Club: Decodable {
    let id: String
    var name: String
    var description: String
    var isPrivate: Bool
    var location: GeoJSON
    var city: String
    var state: String
    var country: String
    var imageURL: String
    var members: [Member]
    var rules: [String]
    var createdAt: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        isPrivate = try values.decode(Bool.self, forKey: .isPrivate)
        location = try values.decode(GeoJSON.self, forKey: .location)
        city = try values.decode(String.self, forKey: .city)
        state = try values.decode(String.self, forKey: .state)
        country = try values.decode(String.self, forKey: .country)
        imageURL = try values.decode(String.self, forKey: .imageURL)
        members = try values.decode([Member].self, forKey: .members)
        rules = try values.decode([String].self, forKey: .rules)
        createdAt = try values.decode(String.self, forKey: .createdAt)
    }
        
    /// For testing purposes
    init(owner: String, name: String, description: String, isPrivate: Bool, location:GeoJSON, city: String, state:String, country: String, imageURL:String, members:[Member], rules:[String], createdAt: String) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
        self.isPrivate = isPrivate
        self.location = location
        self.city = city
        self.state = state
        self.country = country
        self.imageURL = imageURL
        self.members = members
        self.rules = rules
        self.createdAt = createdAt
    }
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case isPrivate
        case location
        case city
        case state
        case country
        case imageURL
        case members
        case rules
        case createdAt
    }
    
}

struct Member: Decodable {
    let id: String
    let uuid: String
    let role: String
    let joinedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case uuid
        case role
        case joinedAt
    }
}
