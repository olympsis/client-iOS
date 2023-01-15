//
//  LoginResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/8/22.
//

import Foundation

struct LoginResponse: Decodable {
    let firstName       : String
    let lastName        : String
    let email           : String
    let sessionToken    : String
}
