//
//  ChatTokenRequest.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/1/23.
//

import Foundation

class ChatTokenRequestDao: Dao {
    var id: String = ""
    
    init(id: String){
        self.id = id
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        
        id = try container.decode(String.self, forKey: .id)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
    }
}

