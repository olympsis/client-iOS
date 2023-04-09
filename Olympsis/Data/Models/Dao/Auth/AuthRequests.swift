//
//  AuthRequestSignIn.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import Foundation

struct SignInRequest: Codable {
    var firstName: String?
    var lastName: String?
    var email: String?
    var code: String?
    var provider: String?
}


class LoginRequest: Codable {
    var code: String?
    var provider: String?
}
