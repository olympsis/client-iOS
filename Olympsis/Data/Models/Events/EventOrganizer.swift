//
//  Organizer.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

struct Organizer: Codable, Identifiable {
    let type: GROUP_TYPE
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case id
    }
    
    init (type: GROUP_TYPE, id: String) {
        self.type = type
        self.id = id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the type first by getting the raw Int value
        let typeInt = try container.decode(Int.self, forKey: .type)
        self.type = numberToGroupType(number: typeInt)
        
        // Decode the id
        self.id = try container.decode(String.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode the type by converting enum to Int
        try container.encode(type.toInt(), forKey: .type)
        
        // Encode the id
        try container.encode(id, forKey: .id)
    }
}
