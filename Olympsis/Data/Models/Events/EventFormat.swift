//
//  Format.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

class EventFormatConfig: Codable {
    // Type identifiers
    var isCompetition: Bool?
    var isCompetitionGame: Bool?
    var parentCompetitionID: String?
    var competitionState: String? // "not_started", "in_progress", "completed"
    
    // Format details
    var formats: [CompetitionFormats]?
    var rounds: Int32?
    var currentRound: Int32?
    var bracketData: [String: Any]?
    
    // Registration period
    var registrationStart: Date?
    var registrationEnd: Date?
    var allowLateRegistration: Bool?
    
    // Custom coding keys for JSON/BSON field mapping
    enum CodingKeys: String, CodingKey {
        case isCompetition = "is_competition"
        case isCompetitionGame = "is_competition_game"
        case parentCompetitionID = "parent_competition_id"
        case competitionState = "competition_state"
        case formats
        case rounds
        case currentRound = "current_round"
        case bracketData = "bracket_data"
        case registrationStart = "registration_start"
        case registrationEnd = "registration_end"
        case allowLateRegistration = "allow_late_registration"
    }
    
    // Initializer with default nil values
    init(isCompetition: Bool? = nil,
         isCompetitionGame: Bool? = nil,
         parentCompetitionID: String? = nil,
         competitionState: String? = nil,
         formats: [CompetitionFormats]? = nil,
         rounds: Int32? = nil,
         currentRound: Int32? = nil,
         bracketData: [String: Any]? = nil,
         registrationStart: Date? = nil,
         registrationEnd: Date? = nil,
         allowLateRegistration: Bool? = nil) {
        
        self.isCompetition = isCompetition
        self.isCompetitionGame = isCompetitionGame
        self.parentCompetitionID = parentCompetitionID
        self.competitionState = competitionState
        self.formats = formats
        self.rounds = rounds
        self.currentRound = currentRound
        self.bracketData = bracketData
        self.registrationStart = registrationStart
        self.registrationEnd = registrationEnd
        self.allowLateRegistration = allowLateRegistration
    }
    
    // Required decoder init for Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Create date formatter for ISO8601 format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        isCompetition = try container.decodeIfPresent(Bool.self, forKey: .isCompetition)
        isCompetitionGame = try container.decodeIfPresent(Bool.self, forKey: .isCompetitionGame)
        parentCompetitionID = try container.decodeIfPresent(String.self, forKey: .parentCompetitionID)
        competitionState = try container.decodeIfPresent(String.self, forKey: .competitionState)
        
        formats = try container.decodeIfPresent([CompetitionFormats].self, forKey: .formats)
        rounds = try container.decodeIfPresent(Int32.self, forKey: .rounds)
        currentRound = try container.decodeIfPresent(Int32.self, forKey: .currentRound)
        
        // Handle JSON for bracket data
        if let bracketDataString = try container.decodeIfPresent(String.self, forKey: .bracketData),
           let data = bracketDataString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            bracketData = json
        }
        
        // Handle date fields with string support
        if let startString = try container.decodeIfPresent(String.self, forKey: .registrationStart),
           let parsedDate = dateFormatter.date(from: startString) {
            registrationStart = parsedDate
        } else if let startInt = try container.decodeIfPresent(Int.self, forKey: .registrationStart) {
            registrationStart = Date(timeIntervalSince1970: TimeInterval(startInt))
        } else {
            registrationStart = try container.decodeIfPresent(Date.self, forKey: .registrationStart)
        }
        
        if let endString = try container.decodeIfPresent(String.self, forKey: .registrationEnd),
           let parsedDate = dateFormatter.date(from: endString) {
            registrationEnd = parsedDate
        } else if let endInt = try container.decodeIfPresent(Int.self, forKey: .registrationEnd) {
            registrationEnd = Date(timeIntervalSince1970: TimeInterval(endInt))
        } else {
            registrationEnd = try container.decodeIfPresent(Date.self, forKey: .registrationEnd)
        }
        
        allowLateRegistration = try container.decodeIfPresent(Bool.self, forKey: .allowLateRegistration)
    }
    
    // Encoder implementation for Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(isCompetition, forKey: .isCompetition)
        try container.encodeIfPresent(isCompetitionGame, forKey: .isCompetitionGame)
        try container.encodeIfPresent(parentCompetitionID, forKey: .parentCompetitionID)
        try container.encodeIfPresent(competitionState, forKey: .competitionState)
        
        try container.encodeIfPresent(formats.map { $0.map(\.rawValue) }, forKey: .formats)
        try container.encodeIfPresent(rounds, forKey: .rounds)
        try container.encodeIfPresent(currentRound, forKey: .currentRound)
        
        // Handle the bracketData encoding
        if let bracketData = bracketData,
           let jsonData = try? JSONSerialization.data(withJSONObject: bracketData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try container.encode(jsonString, forKey: .bracketData)
        }
        
        try container.encodeIfPresent(registrationStart?.ISO8601Format(), forKey: .registrationStart)
        try container.encodeIfPresent(registrationEnd?.ISO8601Format(), forKey: .registrationEnd)
        try container.encodeIfPresent(allowLateRegistration, forKey: .allowLateRegistration)
    }
}
