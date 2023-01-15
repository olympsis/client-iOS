//
//  ChangeRankDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/15/23.
//

import Foundation

class ChangeRankDao: Dao {
    var role: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(String.self, forKey: .role)
        try super.init(from: decoder)
    }
    
    init(role: String) {
        self.role = role
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
    }
    
    enum CodingKeys: String, CodingKey {
        case role
    }
}
