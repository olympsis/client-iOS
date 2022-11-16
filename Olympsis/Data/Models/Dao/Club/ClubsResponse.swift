//
//  ClubsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

/// The Fields Response is a struct conforms to the response of the api to get a list of fields, and decodes it.
struct ClubsResponse: Decodable {
    let totalClubs: Int
    let clubs: [Club]
    
    enum CodingKeys: String, CodingKey {
        case totalClubs = "totalClubs"
        case clubs = "clubs"
    }
}
