//
//  UserNameRequest.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import Foundation

class UserNameRequest: Dao {
    var userName: String = ""
    
    init(name:String){
        userName = name
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        
        userName = try container.decode(String.self, forKey: .userName)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case userName
    }
}
