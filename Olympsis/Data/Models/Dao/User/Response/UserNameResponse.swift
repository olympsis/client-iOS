//
//  UserNameResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import Foundation
class UserNameResponse: Codable {
    var isFound: Bool
    
    enum CodingKeys: String, CodingKey {
        case isFound
    }
}
