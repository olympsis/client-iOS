//
//  Participant.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

class Participant: Codable, Hashable {
    var id: String
    var user: UserSnippet?
    var status: EVENT_RSVP_STATUS
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case status
        case createdAt = "created_at"
    }
    
    init(id: String,
         user: UserSnippet? = nil,
         status: EVENT_RSVP_STATUS,
         createdAt: Date) {
        self.id = id
        self.user = user
        self.status = status
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
        user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        
        let rawStatus = try container.decode(Int.self, forKey: .status)
        status = numberToEventRSVPStatus(rawStatus)
        
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
        try container.encodeIfPresent(user, forKey: .user)
        try container.encode(status.toInt(), forKey: .status)
        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
    }
    
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class ParticipantDao: Codable {
    var id: String?
    var userID: String?
    var status: EVENT_RSVP_STATUS?
    var eventID: String?
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case status
        case eventID = "event_id"
        case createdAt = "created_at"
    }
    
    init(id: String? = nil,
         userID: String? = nil,
         status: EVENT_RSVP_STATUS? = nil,
         eventID: String? = nil,
         createdAt: Date? = nil) {
        self.id = id
        self.userID = userID
        self.status = status
        self.eventID = eventID
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        
        let statusInt = try container.decodeIfPresent(Int.self, forKey: .status) ?? 0
        status = numberToEventRSVPStatus(statusInt)
        
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(status?.toInt(), forKey: .status)
        try container.encodeIfPresent(eventID, forKey: .eventID)
        try container.encodeIfPresent(createdAt?.ISO8601Format(), forKey: .createdAt)
    }
}

class ParticipantsConfig: Codable {
    var hasWaitlist: Bool?
    var minParticipants: Int?
    var maxParticipants: Int?
    
    enum CodingKeys: String, CodingKey {
        case hasWaitlist = "has_waitlist"
        case minParticipants = "min_participants"
        case maxParticipants = "max_participants"
    }
    
    init(hasWaitlist: Bool? = nil,
         minParticipants: Int? = nil,
         maxParticipants: Int? = nil) {
        self.hasWaitlist = hasWaitlist
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasWaitlist = try container.decodeIfPresent(Bool.self, forKey: .hasWaitlist)
        minParticipants = try container.decodeIfPresent(Int.self, forKey: .minParticipants)
        maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hasWaitlist, forKey: .hasWaitlist)
        try container.encodeIfPresent(minParticipants, forKey: .minParticipants)
        try container.encodeIfPresent(maxParticipants, forKey: .maxParticipants)
    }
}
