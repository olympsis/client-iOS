//
//  Field.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct Field: Decodable {
    let id: String
    let owner: String
    var name: String
    var images: [String]
    var location: GeoJSON
    var city: String
    var state: String
    var country: String
    var isPublic: Bool
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        owner = try values.decode(String.self, forKey: .owner)
        name = try values.decode(String.self, forKey: .name)
        images = try values.decode([String].self, forKey: .images)
        location = try values.decode(GeoJSON.self, forKey: .location)
        city = try values.decode(String.self, forKey: .city)
        state = try values.decode(String.self, forKey: .state)
        country = try values.decode(String.self, forKey: .country)
        isPublic = try values.decode(Bool.self, forKey: .isPublic)
    }
        
    /// For testing purposes 
    init(owner: String, name: String, images:[String], location:GeoJSON, city: String, state:String, country: String, isPublic:Bool) {
        id = UUID().uuidString
        self.owner = owner
        self.name = name
        self.images = images
        self.location = location
        self.city = city
        self.state = state
        self.country = country
        self.isPublic = isPublic
    }
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case owner
        case name
        case images
        case location
        case city
        case state
        case country
        case isPublic
    }
    
}

struct GeoJSON: Decodable {
    let type: String
    let coordinates: [String]
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}
