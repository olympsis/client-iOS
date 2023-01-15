//
//  UpdateFriendRequest.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/23/22.
//

import Foundation
class UpdateFriendRequestDao: Dao {
    var status: String
    
    init(_status: String) {
        status = _status
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(String.self, forKey: .status)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case status
    }
}
