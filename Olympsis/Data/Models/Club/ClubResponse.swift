//
//  CreateClubResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/23/23.
//

import Foundation

struct ClubResponse: Codable {
    var token: String
    var club: Club
    
    enum CodingKeys: String, CodingKey {
        case token
        case club
    }
}
