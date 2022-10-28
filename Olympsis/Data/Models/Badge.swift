//
//  Badge.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

class Badge: Codable {
    let badgeID: String
    let iconURL: String
    let dateAchieved: Date
    
    enum CodingKeys: String, CodingKey {
        case badgeID
        case iconURL
        case dateAchieved
    }
}
