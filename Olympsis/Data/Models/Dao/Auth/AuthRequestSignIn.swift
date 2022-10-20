//
//  AuthRequestSignIn.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import Foundation

class AuthRequestSignIn: Dao {
    var firstName: String?
    var lastName: String?
    var email: String?
    var token: String?
    
    override init() {
        firstName = ""
        lastName = ""
        email = ""
        token = ""
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case token
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        token = try container.decode(String.self, forKey: .token)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(token, forKey: .token)
        
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

class AuthRequestLogin: Dao {
    var token: String?
    
    override init() {
        token = ""
        super.init()
    }
    
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
