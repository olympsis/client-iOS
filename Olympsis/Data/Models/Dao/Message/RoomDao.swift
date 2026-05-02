//
//  RoomDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/7/23.
//

import Foundation

class RoomDao: Dao {
    let owner: String?
    let name: String
    let type: String?
    let members: [ChatMember]?
    
    init(owner: String?=nil, name: String, type: String?=nil, members: [ChatMember]?=nil) {
        self.owner = owner
        self.name = name
        self.type = type
        self.members = members
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.owner = try container.decodeIfPresent(String.self, forKey: .owner)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.members = try container.decodeIfPresent([ChatMember].self, forKey: .members)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner, forKey: .owner)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(members, forKey: .members)
        
    }
    
    enum CodingKeys: String, CodingKey {
        case owner
        case name
        case type
        case members
    }
}


