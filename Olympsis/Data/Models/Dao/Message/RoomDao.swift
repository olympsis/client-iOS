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
        fatalError("init(from:) has not been implemented")
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


