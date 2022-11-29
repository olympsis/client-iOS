//
//  UpdateApplicationDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

class UpdateApplicationDao: Dao {
    let clubId: String
    let status: String
    
    init(_clubId: String, _status: String){
        self.clubId = _clubId
        self.status = _status
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clubId, forKey: .clubId)
        try container.encode(status, forKey: .status)
    }
    
    enum CodingKeys: String, CodingKey {
        case clubId
        case status
    }
}
