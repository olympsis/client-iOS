//
//  Event.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

class Event: Codable {
    let id: String
    let ownerId: String
    var clubId: String
    var fieldId: String
    var imageURL: String
    var title: String
    var body: String
    var level: Int
    var status: String
    var startTime: String
    var actualStartTime: String
    var stopTime: String
    var participants: [String]
    var likes: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case ownerId
        case clubId
        case fieldId
        case imageURL
        case title
        case body
        case level
        case status
        case startTime
        case actualStartTime
        case stopTime
        case participants
        case likes
    }
    
}
