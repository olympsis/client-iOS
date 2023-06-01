//
//  EventModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/31/23.
//

import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let poster: String
    let clubID: String
    let fieldID: String
    let imageURL: String
    let title: String
    let body: String
    let sport: String
    let level: Int8
    var status: String
    var startTime: Int64
    var actualStartTime: Int64?
    var stopTime: Int64?
    let maxParticipants: Int8
    var participants: [Participant]?
    let likes: [Like]?
    let visibility: String
    let createdAt: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
        case poster
        case clubID = "club_id"
        case fieldID = "field_id"
        case imageURL = "image_url"
        case title
        case body
        case sport
        case level
        case status
        case startTime = "start_time"
        case actualStartTime = "actual_start_time"
        case stopTime = "stop_time"
        case maxParticipants = "max_participants"
        case participants
        case likes
        case visibility
        case createdAt = "created_at"
    }
}

struct Participant: Codable, Identifiable {
    let id: String?
    let uuid: String
    let data: UserData?
    let status: String
    let createdAt: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case data
        case status
        case createdAt = "created_at"
    }
}

struct Like: Codable, Identifiable {
    let id: String?
    let uuid: String
    let createdAt: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case createdAt = "created_at"
    }
}
