//
//  Team.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

class Team: Codable {
    var id: String
    var name: String
    var members: [Participant]
    var eventID: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
        case eventID = "event_id"
        case createdAt = "created_at"
    }
    
    init(id: String,
         name: String,
         members: [Participant],
         eventID: String,
         createdAt: Date) {
        self.id = id
        self.name = name
        self.members = members
        self.eventID = eventID
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Create date formatter for ISO8601 format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        members = try container.decode([Participant].self, forKey: .members)
        eventID = try container.decode(String.self, forKey: .eventID)
        
        // Handle date decoding with string support
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let parsedDate = dateFormatter.date(from: createdAtString) {
            createdAt = parsedDate
        } else if let createdAtInt = try container.decodeIfPresent(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt))
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(members, forKey: .members)
        try container.encode(eventID, forKey: .eventID)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
}

class TeamDao: Codable {
    var id: String?
    var name: String?
    var members: [Participant]?
    var eventID: String?
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
        case eventID = "event_id"
        case createdAt = "created_at"
    }
    
    init(id: String? = nil,
         name: String? = nil,
         members: [Participant]? = nil,
         eventID: String? = nil,
         createdAt: Date? = nil) {
        self.id = id
        self.name = name
        self.members = members
        self.eventID = eventID
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        members = try container.decodeIfPresent([Participant].self, forKey: .members)
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(members, forKey: .members)
        try container.encodeIfPresent(eventID, forKey: .eventID)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

class TeamsConfig: Codable {
    var hasWaitlist: Bool?
    var hideTeams: Bool?
    
    var minTeams: Int32?
    var maxTeams: Int32?
    var maxTeamSize: Int32?
    
    enum CodingKeys: String, CodingKey {
        case hasWaitlist = "has_waitlist"
        case hideTeams = "hide_teams"
        
        case minTeams = "min_teams"
        case maxTeams = "max_teams"
        case maxTeamSize = "max_team_size"
    }
    
    init(hasWaitlist: Bool? = nil,
         hideTeams: Bool? = nil,
         minTeams: Int32? = nil,
         maxTeams: Int32? = nil,
         maxTeamSize: Int32? = nil) {
        self.hasWaitlist = hasWaitlist
        self.hideTeams = hideTeams
        self.minTeams = minTeams
        self.maxTeams = maxTeams
        self.maxTeamSize = maxTeamSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasWaitlist = try container.decodeIfPresent(Bool.self, forKey: .hasWaitlist)
        hideTeams = try container.decodeIfPresent(Bool.self, forKey: .hideTeams)
        minTeams = try container.decodeIfPresent(Int32.self, forKey: .minTeams)
        maxTeams = try container.decodeIfPresent(Int32.self, forKey: .maxTeams)
        maxTeamSize = try container.decodeIfPresent(Int32.self, forKey: .maxTeamSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hasWaitlist, forKey: .hasWaitlist)
        try container.encodeIfPresent(hideTeams, forKey: .hideTeams)
        try container.encodeIfPresent(minTeams, forKey: .minTeams)
        try container.encodeIfPresent(maxTeams, forKey: .maxTeams)
        try container.encodeIfPresent(maxTeamSize, forKey: .maxTeamSize)
    }
}
