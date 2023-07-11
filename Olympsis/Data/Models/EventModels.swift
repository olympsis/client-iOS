//
//  EventModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/31/23.
//

import SwiftUI
import Foundation

class Event: Codable, Identifiable, ObservableObject {
    
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
    var data: EventData?
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
    
    init(id: String? = nil, poster: String? = nil, clubID: String? = nil, fieldID: String? = nil, imageURL: String? = nil, title: String? = nil, body: String? = nil, sport: String? = nil, level: Int? = nil, status: String? = nil, startTime: Int64? = nil, actualStartTime: Int64? = nil, stopTime: Int64? = nil, maxParticipants: Int? = nil, participants: [Participant]? = nil, likes: [Like]? = nil, visibility: String? = nil, data: EventData? = nil, createdAt: Int64? = nil) {
            self.id = id
            self.poster = poster
            self.clubID = clubID
            self.fieldID = fieldID
            self.imageURL = imageURL
            self.title = title
            self.body = body
            self.sport = sport
            self.level = level
            self.status = status
            self.startTime = startTime
            self.actualStartTime = actualStartTime
            self.stopTime = stopTime
            self.maxParticipants = maxParticipants
            self.participants = participants
            self.likes = likes
            self.visibility = visibility
            self.data = data
            self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(String.self, forKey: .id)
            poster = try container.decodeIfPresent(String.self, forKey: .poster)
            clubID = try container.decodeIfPresent(String.self, forKey: .clubID)
            fieldID = try container.decodeIfPresent(String.self, forKey: .fieldID)
            imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            body = try container.decodeIfPresent(String.self, forKey: .body)
            sport = try container.decodeIfPresent(String.self, forKey: .sport)
            level = try container.decodeIfPresent(Int.self, forKey: .level)
            status = try container.decodeIfPresent(String.self, forKey: .status)
            startTime = try container.decodeIfPresent(Int64.self, forKey: .startTime)
            actualStartTime = try container.decodeIfPresent(Int64.self, forKey: .actualStartTime)
            stopTime = try container.decodeIfPresent(Int64.self, forKey: .stopTime)
            maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
            participants = try container.decodeIfPresent([Participant].self, forKey: .participants)
            likes = try container.decodeIfPresent([Like].self, forKey: .likes)
            visibility = try container.decodeIfPresent(String.self, forKey: .visibility)
            data = try container.decodeIfPresent(EventData.self, forKey: .data)
            createdAt = try container.decodeIfPresent(Int64.self, forKey: .createdAt)
        }
}

struct Participant: Codable, Identifiable, Hashable {
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
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

struct Like: Codable, Identifiable, Hashable {
    static func == (lhs: Like, rhs: Like) -> Bool {
        return lhs.id == rhs.id
    }
    
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

extension [Event] {
    func mostRecentForUser(uuid: String) -> Event? {
        guard self.count > 0 else {
            return nil
        }
        var filtered = self.filter{ $0.participants?.first(where: { $0.uuid == uuid }) != nil }
        filtered = filtered.sorted { $0.startTime! > $1.startTime! }
        
        guard filtered.count > 0 else {
            return nil
        }
        
        return filtered[0]
    }
    
    func filterByClubID(id: String) -> [Event]? {
        guard self.count > 0 else {
            return nil
        }
        
        let filtered = self.filter { $0.clubID! == id }
        guard filtered.count > 0 else {
            return nil
        }
        
        return filtered.sorted { $0.startTime! > $1.startTime! }
    }
}
