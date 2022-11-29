//
//  Field.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct Field: Decodable, Identifiable {
    let id: String
    let owner: String
    var name: String
    var notes: String
    var sports: [String]
    var images: [String]
    var location: GeoJSON
    var city: String
    var state: String
    var country: String
    var isPublic: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case owner
        case name
        case notes
        case sports
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
    let coordinates: [Double]
}
