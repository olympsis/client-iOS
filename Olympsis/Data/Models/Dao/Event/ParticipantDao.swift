//
//  ParticipantDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

class ParticipantDao: Dao {
    let uuid: String
    let status: String
    
    init(_uuid: String, _status: String) {
        self.uuid = _uuid
        self.status = _status
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(status, forKey: .status)
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case status
    }
}
