//
//  ClubApplicationRequest.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

class ClubApplicationRequestDao: Dao {
    var clubId: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clubId = try container.decode(String.self, forKey: .clubId)
        try super.init(from: decoder)
    }
    
    init(clubId: String) {
        self.clubId = clubId
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clubId, forKey: .clubId)
    }
    
    enum CodingKeys: String, CodingKey {
        case clubId
    }
}
