//
//  EventModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/31/23.
//

import Foundation

struct Event: Codable, Identifiable {
    let id: String?
    let poster: String?
    let clubID: String?
    let fieldID: String?
    let imageURL: String?
    let title: String?
    let body: String?
    let sport: String?
    let level: Int?
    var status: String?
    var startTime: Int64?
    var actualStartTime: Int64?
    var stopTime: Int64?
    let maxParticipants: Int?
    var participants: [Participant]?
    let likes: [Like]?
    let visibility: String?
    let data: EventData?
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
        case data
        case createdAt = "created_at"
    }
}

struct Participant: Codable, Identifiable {
    let id: String?
    let uuid: String
    var data: UserData?
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

struct EventData: Codable {
    let poster: UserData?
    let club: Club?
    let field: Field?
}

/// The Fields Response is a struct conforms to the response of the api to get a list of fields, and decodes it.
struct EventsResponse: Decodable {
    let totalEvents: Int
    let events: [Event]
    
    enum CodingKeys: String, CodingKey {
        case totalEvents = "total_events"
        case events
    }
}
