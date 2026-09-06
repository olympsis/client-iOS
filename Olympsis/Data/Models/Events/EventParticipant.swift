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
    var isAnonymous: Bool
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case status
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
    }
    
    init(id: String,
         user: UserSnippet? = nil,
         status: EVENT_RSVP_STATUS,
         isAnonymous: Bool = false,
         createdAt: Date) {
        self.id = id
        self.user = user
        self.status = status
        self.isAnonymous = isAnonymous
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
        
        // RSVP status arrives as a legacy integer (0/1/2/3) from current server builds
        // and as a string ("YES"/...) once the server flips formats. Accept either so a
        // format change can't break Event decoding; default to .Maybe on anything else.
        if let rawInt = try? container.decode(Int.self, forKey: .status) {
            status = numberToEventRSVPStatus(rawInt)
        } else if let rawString = try? container.decode(String.self, forKey: .status) {
            status = stringToEventRSVPStatus(rawString)
        } else {
            status = .Maybe
        }
        
        isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous) ?? false
        
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
        try container.encodeIfPresent(isAnonymous, forKey: .isAnonymous)
        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
    }
    
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// What the server answers with when a participant row is created or changed.
///
/// The status matters as much as the id: the server may not have given the
/// caller what they asked for — an RSVP to a full event comes back WAITLIST —
/// and the client has no other way to know that happened.
struct ParticipantResponse: Decodable {
    let id: String
    let status: EVENT_RSVP_STATUS?

    enum CodingKeys: String, CodingKey {
        case id
        case status
    }

    init(id: String, status: EVENT_RSVP_STATUS?) {
        self.id = id
        self.status = status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        // Int-or-string, same as `Participant`. Left nil rather than defaulted
        // when absent so the caller can fall back to the status it requested —
        // a server build from before this field existed must not be read as
        // "you were downgraded to Maybe".
        if let rawInt = try? container.decode(Int.self, forKey: .status) {
            status = numberToEventRSVPStatus(rawInt)
        } else if let rawString = try? container.decode(String.self, forKey: .status) {
            status = stringToEventRSVPStatus(rawString)
        } else {
            status = nil
        }
    }
}

class ParticipantDao: Codable {
    var id: String?
    var userID: String?
    var status: EVENT_RSVP_STATUS?
    var eventID: String?
    var isAnonymous: Bool?
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case status
        case eventID = "event_id"
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
    }
    
    init(id: String? = nil,
         userID: String? = nil,
         status: EVENT_RSVP_STATUS? = nil,
         eventID: String? = nil,
         isAnonymous: Bool? = nil,
         createdAt: Date? = nil) {
        self.id = id
        self.userID = userID
        self.status = status
        self.eventID = eventID
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        
        // RSVP status arrives as a legacy integer (0/1/2/3) from current server builds
        // and as a string ("YES"/...) once the server flips formats. Accept either so a
        // format change can't break Event decoding; a missing/unknown status becomes
        // .Maybe (safer than the old `?? 0`) rather than nil.
        if let rawInt = try? container.decode(Int.self, forKey: .status) {
            status = numberToEventRSVPStatus(rawInt)
        } else if let rawString = try? container.decode(String.self, forKey: .status) {
            status = stringToEventRSVPStatus(rawString)
        } else {
            status = .Maybe
        }
        
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(status?.toInt(), forKey: .status)
        try container.encodeIfPresent(eventID, forKey: .eventID)
        try container.encodeIfPresent(isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(createdAt?.ISO8601Format(), forKey: .createdAt)
    }
}

class ParticipantsConfig: Codable {
    var hasWaitlist: Bool? // Enables a wait-list
    var hideParticipants: Bool? // Hide Pre-RSVP
    
    var minParticipants: Int?
    var maxParticipants: Int?
    
    enum CodingKeys: String, CodingKey {
        case hasWaitlist = "has_waitlist"
        case hideParticipants = "hide_participants"
        case minParticipants = "min_participants"
        case maxParticipants = "max_participants"
    }
    
    init(hasWaitlist: Bool? = nil,
         hideParticipants: Bool? = nil,
         minParticipants: Int? = nil,
         maxParticipants: Int? = nil) {
        self.hasWaitlist = hasWaitlist
        self.hideParticipants = hideParticipants
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasWaitlist = try container.decodeIfPresent(Bool.self, forKey: .hasWaitlist)
        hideParticipants = try container.decodeIfPresent(Bool.self, forKey: .hideParticipants)
        minParticipants = try container.decodeIfPresent(Int.self, forKey: .minParticipants)
        maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hasWaitlist, forKey: .hasWaitlist)
        try container.encodeIfPresent(hideParticipants, forKey: .hideParticipants)
        try container.encodeIfPresent(minParticipants, forKey: .minParticipants)
        try container.encodeIfPresent(maxParticipants, forKey: .maxParticipants)
    }
}
