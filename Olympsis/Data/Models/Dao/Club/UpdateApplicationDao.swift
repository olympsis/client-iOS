//
//  UpdateApplicationDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

class UpdateApplicationDao: Dao {

    let status: String
    
    init(_clubId: String, _status: String){
        self.status = _status
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(String.self, forKey: .status)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
    }
    
    enum CodingKeys: String, CodingKey {
        case status
    }
}
