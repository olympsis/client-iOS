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
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case token
    }
}

struct AuthResponse: Codable {
    var uuid: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case token
    }
}

struct AuthUser: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let birthdate: Date
    let gender: Gender
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case birthdate = "birthdate"
        case gender
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        
        let rawDate = try container.decode(String.self, forKey: .birthdate)
        birthdate = try parseDate(from: rawDate)
        
        let rawGender = try container.decode(String.self, forKey: .gender)
        gender = Gender(rawValue: rawGender) ?? .PreferNotToSay
    }
}

struct AuthUserDao: Encodable {
    var firstName: String?=nil
    var lastName: String?=nil
    var email: String?=nil
    var birthdate: Date?=nil
    var gender: Gender?=nil
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case birthdate = "birthdate"
        case gender
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(birthdate?.ISO8601Format(), forKey: .birthdate)
        try container.encodeIfPresent(gender?.rawValue, forKey: .gender)
    }
}
