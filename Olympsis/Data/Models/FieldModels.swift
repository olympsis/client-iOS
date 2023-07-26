//
//  FieldModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation

class Field: Codable, Identifiable {
    let id: String
    let name: String
    let owner: Ownership
    let description: String
    let sports: [String]
    let images: [String]
    let location: GeoJSON
    let city: String
    let state: String
    let country: String
    
    private enum CodingKeys: String, CodingKey {
       case id = "id"
       case name
       case owner
       case description
       case sports
       case images
       case location
       case city
       case state
       case country
    }
    
    init(id: String, name: String, owner: Ownership, description: String, sports: [String], images: [String], location: GeoJSON, city: String, state: String, country: String) {
        self.id = id
        self.name = name
        self.owner = owner
        self.description = description
        self.sports = sports
        self.images = images
        self.location = location
        self.city = city
        self.state = state
        self.country = country
    }
}

struct GeoJSON: Codable, Hashable {
    static func == (lhs: GeoJSON, rhs: GeoJSON) -> Bool {
        return (lhs.coordinates[0] == rhs.coordinates[0]) && (lhs.coordinates[1] == rhs.coordinates[1])
    }
    let type: String
    let coordinates: [Double]
}

struct Ownership: Codable, Hashable {
    static func == (lhs: Ownership, rhs: Ownership) -> Bool {
        return lhs.name == rhs.name
    }
    let name: String
    let type: String
}

struct FieldsResponse: Codable {
    let fields: [Field]
    let totalFields: Int
    
    private enum CodingKeys: String, CodingKey {
        case fields
        case totalFields = "total_fields"
    }
}
