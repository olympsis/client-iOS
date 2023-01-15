//
//  Event.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

struct Event: Decodable, Identifiable {
    let id: String
    let ownerId: String
    var ownerData: UserPeek?
    var clubId: String
    var fieldId: String
    var imageURL: String
    var title: String
    var body: String
    var sport: String
    var level: Int
    var status: String
    var startTime: Int
    var actualStartTime: Int?
    var stopTime: Int?
    var maxParticipants: Int
    var participants: [Participant]?
    var likes: [Like]?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case ownerData
        case clubId
        case fieldId
        case imageURL
        case title
        case body
        case sport
        case level
        case status
        case startTime
        case actualStartTime
        case stopTime
        case maxParticipants
        case participants
        case likes
    }
}

