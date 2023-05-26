//
//  AuthModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/24/23.
//

import Foundation

struct AuthRequest: Codable {
    var firstName: String?
    var lastName: String?
    var email: String?
    var code: String
    var provider: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case code
        case provider
    }
}

struct AuthResponse: Codable {
    var firstName: String?
    var lastName: String?
    var email: String?
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case token
    }
}
