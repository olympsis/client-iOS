//
//  AuthResponseDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import Foundation

struct AuthResponse: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case token
    }
}
