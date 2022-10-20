//
//  UserNameResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import Foundation
class UserNameResponse: Dao {
    var isFound: Bool
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isFound = try container.decode(Bool.self, forKey: .isFound)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isFound, forKey: .isFound)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case isFound
    }
}
