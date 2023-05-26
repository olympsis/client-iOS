//
//  FieldModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation

struct Field: Codable, Identifiable {
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
}

struct GeoJSON: Codable {
    let type: String
    let coordinates: [Double]
}

struct Ownership: Codable {
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
