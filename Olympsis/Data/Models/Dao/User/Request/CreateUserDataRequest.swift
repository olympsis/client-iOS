//
//  CreateUserDataRequest.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import Foundation

class CreateUserDataRequest: Dao {
    var userName: String = ""
    var sports:[String] = []
    
    init(userName:String, sports:[String]){
        self.userName = userName
        self.sports = sports;
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        
        userName = try container.decode(String.self, forKey: .userName)
        sports = try container.decode([String].self, forKey: .sports)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(sports, forKey: .sports)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case userName
        case sports
    }
}
