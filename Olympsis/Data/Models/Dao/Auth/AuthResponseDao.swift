//
//  AuthResponseDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import Foundation

class AuthResponseDao: Dao {
    var token: String = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        
        token = try container.decode(String.self, forKey: .token)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}
