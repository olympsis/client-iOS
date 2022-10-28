//
//  Trophy.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

class Trophy: Codable {
    let trophyID: String
    let iconURL: String
    let tournament: String
    let achievedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case trophyID
        case iconURL
        case tournament
        case achievedDate
    }
    
}
