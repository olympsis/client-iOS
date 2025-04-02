//
//  EventModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/31/23.
//

import SwiftUI
import Foundation
import CoreLocation

enum EventError: Error {
    case unknown
    case unsafeMedia
    case failedToAddParticipant
    case failedToRemoveParticipant
    case failedToAddTeam
    case failedToRemoveTeam
    case failedToAddComment
    case failedToRemoveComment
}


class Event: Decodable, Identifiable, ObservableObject, Hashable {
    let id: String
    let poster: UserSnippet?
    var organizers: [Organizer]
    var venues: [VenueDescriptor]
    
    var mediaURL: String
    var mediaType: MEDIA_TYPES
    
    var title: String
    var body: String
    var tags: [String]
    var sports: [String]

    var formatConfig: EventFormatConfig?
    
    @Published var startTime: Date
    @Published var stopTime: Date
    
    @Published var participants: [Participant]
    @Published var participantsWaitlist: [Participant]
    var participantsConfig: ParticipantsConfig?
    
    @Published var teams: [Team]
    @Published var teamsWaitlist: [Team]
    var teamsConfig: TeamsConfig?
    
    @Published var comments: [EventComment]
    
    var visibility: EVENT_VISIBILITY_TYPES
    var externalLink: String?
    var isSensitive: Bool
    
    let createdAt: Date
    let updatedAt: Date?
    let canceledAt: Date?
    
    var recurrenceConfig: EventRecurrenceConfig?
    
    enum CodingKeys: String, CodingKey {
        case id
        case poster
        case organizers
        case venues
        case venue // For backwards compatibility
        
        case mediaURL = "media_url"
        case mediaType = "media_type"
        
        case title
        case body
        case tags
        case sports
        
        case formatConfig = "format_config"
        
        case startTime = "start_time"
        case stopTime = "stop_time"
        
        case participants
        case participantsWaitlist = "participants_waitlist"
        case participantsConfig = "participants_config"
        
        case teams
        case teamsWaitlist = "teams_waitlist"
        case teamsConfig = "teams_config"
        
        case comments
        
        case visibility
        case externalLink = "external_link"
        case isSensitive = "is_sensitive"
        
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case canceledAt = "canceled_at"
        
        case recurrenceConfig = "recurrence_config"
    }
    
    init(id: String,
         poster: UserSnippet? = nil,
         organizers: [Organizer] = [],
         venues: [VenueDescriptor] = [],
         mediaURL: String,
         mediaType: MEDIA_TYPES,
         title: String,
         body: String,
         tags: [String] = [],
         sports: [String] = [],
         formatConfig: EventFormatConfig? = nil,
         startTime: Date,
         stopTime: Date,
         participants: [Participant] = [],
         participantsWaitlist: [Participant] = [],
         participantsConfig: ParticipantsConfig? = nil,
         teams: [Team] = [],
         teamsWaitlist: [Team] = [],
         teamsConfig: TeamsConfig? = nil,
         comments: [EventComment] = [],
         visibility: EVENT_VISIBILITY_TYPES,
         externalLink: String? = nil,
         isSensitive: Bool = false,
         createdAt: Date,
         updatedAt: Date? = nil,
         canceledAt: Date? = nil,
         recurrenceConfig: EventRecurrenceConfig? = nil) {
         
        self.id = id
        self.poster = poster
        self.organizers = organizers
        self.venues = venues
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        
        self.title = title
        self.body = body
        self.tags = tags
        self.sports = sports
        
        self.formatConfig = formatConfig
        
        self.startTime = startTime
        self.stopTime = stopTime
        
        self.participants = participants
        self.participantsWaitlist = participantsWaitlist
        self.participantsConfig = participantsConfig
        
        self.teams = teams
        self.teamsWaitlist = teamsWaitlist
        self.teamsConfig = teamsConfig
        
        self.comments = comments
        
        self.visibility = visibility
        self.externalLink = externalLink
        self.isSensitive = isSensitive
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.canceledAt = canceledAt
        
        self.recurrenceConfig = recurrenceConfig
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required properties
        id = try container.decode(String.self, forKey: .id)
        poster = try container.decodeIfPresent(UserSnippet.self, forKey: .poster)
        organizers = try container.decodeIfPresent([Organizer].self, forKey: .organizers) ?? []
        
        // Handle venues with backwards compatibility
        if let singleVenue = try container.decodeIfPresent(VenueDescriptor.self, forKey: .venue) {
            venues = [singleVenue]
        } else {
            venues = try container.decodeIfPresent([VenueDescriptor].self, forKey: .venues) ?? []
        }
        
        // Decode media properties with conversion
        mediaURL = try container.decode(String.self, forKey: .mediaURL)
        let mediaTypeRawValue = try container.decode(String.self, forKey: .mediaType)
        mediaType = MEDIA_TYPES(rawValue: mediaTypeRawValue) ?? .image // Provide a default value
        
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        sports = try container.decodeIfPresent([String].self, forKey: .sports) ?? []
        
        formatConfig = try container.decodeIfPresent(EventFormatConfig.self, forKey: .formatConfig)
        
        /// Since we know created_at parsing works, use the same approach for start_time
        let startTimeString = try container.decode(String.self, forKey: .startTime)
        let stopTimeString = try container.decode(String.self, forKey: .stopTime)
        
        startTime = try parseDate(from: startTimeString)
        stopTime = try parseDate(from: stopTimeString)
        
        participants = try container.decodeIfPresent([Participant].self, forKey: .participants) ?? []
        participantsWaitlist = try container.decodeIfPresent([Participant].self, forKey: .participantsWaitlist) ?? []
        participantsConfig = try container.decodeIfPresent(ParticipantsConfig.self, forKey: .participantsConfig)
        
        teams = try container.decodeIfPresent([Team].self, forKey: .teams) ?? []
        teamsWaitlist = try container.decodeIfPresent([Team].self, forKey: .teamsWaitlist) ?? []
        teamsConfig = try container.decodeIfPresent(TeamsConfig.self, forKey: .teamsConfig)
        
        comments = try container.decodeIfPresent([EventComment].self, forKey: .comments) ?? []
        
        // Decode visibility with conversion
        let visibilityRawValue = try container.decode(Int.self, forKey: .visibility)
        visibility = numberToEventVisibilityType(visibilityRawValue)
        
        externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
        
        // Handle createdAt date from string
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = try parseDate(from: createdAtString)
        
        // Handle optional date fields
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = try parseDate(from: updatedAtString)
        } else {
            updatedAt = nil
        }
        
        if let canceledAtString = try container.decodeIfPresent(String.self, forKey: .canceledAt) {
            canceledAt = try parseDate(from: canceledAtString)
        } else {
            canceledAt = nil
        }
        
        recurrenceConfig = try container.decodeIfPresent(EventRecurrenceConfig.self, forKey: .recurrenceConfig)
    }
    
    func update(from event: Event) {
        self.title = event.title
        self.body = event.body
        self.venues = event.venues
        self.participants = event.participants
        self.startTime = event.startTime
        self.stopTime = event.stopTime
        self.mediaURL = event.mediaURL
        self.visibility = event.visibility
        self.externalLink = event.externalLink
        self.organizers = event.organizers
        self.tags = event.tags
        self.sports = event.sports
        self.formatConfig = event.formatConfig
        self.participantsConfig = event.participantsConfig
        self.teams = event.teams
        self.teamsConfig = event.teamsConfig
        self.comments = event.comments
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
}

class EventDao: Codable, Identifiable, ObservableObject {
    let poster: String?
    var organizers: [Organizer]?
    var venues: [VenueDescriptor]?
    var mediaURL: String?
    var mediaType: MEDIA_TYPES?
    var title: String?
    var body: String?
    var tags: [String]?
    let sports: [String]?
    var formatConfig: EventFormatConfig?
    var startTime: Date?
    var stopTime: Date?
    var participantsConfig: ParticipantsConfig?
    var participants: [Participant]?
    var teamsConfig: TeamsConfig?
    var teams: [Team]?
    var visibility: EVENT_VISIBILITY_TYPES?
    let createdAt: Date?
    let updatedAt: Date?
    let canceledAt: Date?
    var externalLink: String?
    var isSensitive: Bool?
    var recurrenceConfig: EventRecurrenceConfig?
    
    enum CodingKeys: String, CodingKey {
        case poster
        case organizers
        case venues
        case mediaURL = "media_url"
        case mediaType = "media_type"
        case title
        case body
        case sports
        case tags
        case formatConfig = "format_config"
        case startTime = "start_time"
        case stopTime = "stop_time"
        case participantsConfig = "participants_config"
        case participants
        case teamsConfig = "teams_config"
        case teams
        case visibility
        case isSensitive = "is_sensitive"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case canceledAt = "canceled_at"
        case externalLink = "external_link"
        case recurrenceConfig = "recurrence_config"
    }
    
    init(
        poster: String? = nil,
        organizers: [Organizer]? = nil,
        venues: [VenueDescriptor]? = nil,
        mediaURL: String? = nil,
        mediaType: MEDIA_TYPES? = nil,
        title: String? = nil,
        body: String? = nil,
        tags: [String]? = nil,
        sports: [String]? = nil,
        formatConfig: EventFormatConfig? = nil,
        startTime: Date? = nil,
        stopTime: Date? = nil,
        participantsConfig: ParticipantsConfig? = nil,
        participants: [Participant]? = nil,
        teamsConfig: TeamsConfig? = nil,
        teams: [Team]? = nil,
        visibility: EVENT_VISIBILITY_TYPES? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        canceledAt: Date? = nil,
        isSensitive: Bool? = nil,
        externalLink: String? = nil,
        recurrenceConfig: EventRecurrenceConfig? = nil
    ) {
        self.poster = poster
        self.organizers = organizers
        self.venues = venues
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.title = title
        self.body = body
        self.sports = sports
        self.tags = tags
        self.formatConfig = formatConfig
        self.startTime = startTime
        self.stopTime = stopTime
        self.participantsConfig = participantsConfig
        self.participants = participants
        self.teamsConfig = teamsConfig
        self.teams = teams
        self.visibility = visibility
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.canceledAt = canceledAt
        self.isSensitive = isSensitive
        self.externalLink = externalLink
        self.recurrenceConfig = recurrenceConfig
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.poster = try container.decodeIfPresent(String.self, forKey: .poster)
        self.organizers = try container.decodeIfPresent([Organizer].self, forKey: .organizers)
        self.venues = try container.decodeIfPresent([VenueDescriptor].self, forKey: .venues)
        self.mediaURL = try container.decodeIfPresent(String.self, forKey: .mediaURL)
        
        // Decode mediaType with conversion from Int if needed
        if let mediaTypeRaw = try container.decodeIfPresent(String.self, forKey: .mediaType) {
            self.mediaType = MEDIA_TYPES(rawValue: mediaTypeRaw)
        } else {
            self.mediaType = nil
        }
        
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.sports = try container.decodeIfPresent([String].self, forKey: .sports)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
        self.formatConfig = try container.decodeIfPresent(EventFormatConfig.self, forKey: .formatConfig)
        
        // Decode timestamps to Date objects
        if let startTimeInt = try container.decodeIfPresent(Int.self, forKey: .startTime) {
            self.startTime = Date(timeIntervalSince1970: TimeInterval(startTimeInt))
        } else {
            self.startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        }
        
        if let stopTimeInt = try container.decodeIfPresent(Int.self, forKey: .stopTime) {
            self.stopTime = Date(timeIntervalSince1970: TimeInterval(stopTimeInt))
        } else {
            self.stopTime = try container.decodeIfPresent(Date.self, forKey: .stopTime)
        }
        
        self.participantsConfig = try container.decodeIfPresent(ParticipantsConfig.self, forKey: .participantsConfig)
        self.participants = try container.decodeIfPresent([Participant].self, forKey: .participants)
        self.teamsConfig = try container.decodeIfPresent(TeamsConfig.self, forKey: .teamsConfig)
        self.teams = try container.decodeIfPresent([Team].self, forKey: .teams)
        
        // Decode visibility with conversion from Int if needed
        if let visibilityInt = try container.decodeIfPresent(Int.self, forKey: .visibility) {
            self.visibility = numberToEventVisibilityType(visibilityInt)
        } else {
            self.visibility = nil
        }
        
        // Decode timestamps to Date objects
        if let createdAtInt = try container.decodeIfPresent(Int.self, forKey: .createdAt) {
            self.createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt))
        } else {
            self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        }
        
        if let updatedAtInt = try container.decodeIfPresent(Int.self, forKey: .updatedAt) {
            self.updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt))
        } else {
            self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        }
        
        if let canceledAtInt = try container.decodeIfPresent(Int.self, forKey: .canceledAt) {
            self.canceledAt = Date(timeIntervalSince1970: TimeInterval(canceledAtInt))
        } else {
            self.canceledAt = try container.decodeIfPresent(Date.self, forKey: .canceledAt)
        }
        
        self.isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
        self.externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        self.recurrenceConfig = try container.decodeIfPresent(EventRecurrenceConfig.self, forKey: .recurrenceConfig)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(organizers, forKey: .organizers)
        try container.encodeIfPresent(venues, forKey: .venues)
        try container.encodeIfPresent(mediaURL, forKey: .mediaURL)
        try container.encodeIfPresent(mediaType?.rawValue, forKey: .mediaType)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(sports, forKey: .sports)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(formatConfig, forKey: .formatConfig)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(stopTime, forKey: .stopTime)
        try container.encodeIfPresent(participantsConfig, forKey: .participantsConfig)
        try container.encodeIfPresent(participants, forKey: .participants)
        try container.encodeIfPresent(teamsConfig, forKey: .teamsConfig)
        try container.encodeIfPresent(teams, forKey: .teams)
        try container.encodeIfPresent(visibility?.rawValue, forKey: .visibility)
        try container.encodeIfPresent(createdAt?.ISO8601Format(), forKey: .createdAt)
        try container.encodeIfPresent(updatedAt?.ISO8601Format(), forKey: .updatedAt)
        try container.encodeIfPresent(canceledAt?.ISO8601Format(), forKey: .canceledAt)
        try container.encodeIfPresent(isSensitive, forKey: .isSensitive)
        try container.encodeIfPresent(externalLink, forKey: .externalLink)
        try container.encodeIfPresent(recurrenceConfig, forKey: .recurrenceConfig)
    }
}

struct Organizer: Codable, Identifiable {
    let type: GROUP_TYPE
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case id
    }
    
    init (type: GROUP_TYPE, id: String) {
        self.type = type
        self.id = id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the type first by getting the raw Int value
        let typeInt = try container.decode(Int.self, forKey: .type)
        self.type = numberToGroupType(number: typeInt)
        
        // Decode the id
        self.id = try container.decode(String.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode the type by converting enum to Int
        try container.encode(type.toInt(), forKey: .type)
        
        // Encode the id
        try container.encode(id, forKey: .id)
    }
}

struct EventsResponse: Decodable {
    let totalEvents: Int
    let events: [Event]
    
    enum CodingKeys: String, CodingKey {
        case totalEvents = "total_events"
        case events
    }
}

struct NewEventDao: Codable {
    var event: EventDao
    var includeHost: Bool
    var recurrence: EventRecurrenceOptions?
    
    enum CodingKeys: String, CodingKey {
        case event
        case includeHost = "include_host"
        case recurrence = "recurrence"
    }
}

class EventRecurrenceOptions: Codable {
    var pattern: EVENT_RECURRENCE_FREQUENCY
    var endTime: Date
    var interval: Int
    
    init(pattern: EVENT_RECURRENCE_FREQUENCY, endTime: Date, interval: Int) {
        self.pattern = pattern
        self.endTime = endTime
        self.interval = interval
    }
    
    // Required decoder init
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode pattern as string and convert to enum
        let patternString = try container.decode(String.self, forKey: .pattern)
        guard let decodedPattern = EVENT_RECURRENCE_FREQUENCY(rawValue: patternString) else {
            throw DecodingError.dataCorruptedError(forKey: .pattern,
                in: container,
                debugDescription: "Invalid pattern value")
        }
        
        pattern = decodedPattern
        endTime = try container.decode(Date.self, forKey: .endTime)
        interval = try container.decode(Int.self, forKey: .interval)
    }
    
    // Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pattern.rawValue, forKey: .pattern)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(interval, forKey: .interval)
    }
    
    enum CodingKeys: String, CodingKey {
        case pattern
        case endTime = "end_time"
        case interval
    }
}

struct EventSharingTemplate {
    var titlePosition: SHARING_TITLE_POSITION
    var timePosition: SHARING_TIME_POSITION
    var venuePosition: SHARING_VENUE_POSITION
}

// MARK: - Event Configurations
class EventFormatConfig: Codable {
    // Type identifiers
    var isCompetition: Bool?
    var isCompetitionGame: Bool?
    var parentCompetitionID: String?
    var competitionState: String? // "not_started", "in_progress", "completed"
    
    // Format details
    var format: CompetitionFormats?
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
        case format
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
         format: CompetitionFormats? = nil,
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
        self.format = format
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
        
        format = try container.decodeIfPresent(CompetitionFormats.self, forKey: .format)
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
        
        try container.encodeIfPresent(format, forKey: .format)
        try container.encodeIfPresent(rounds, forKey: .rounds)
        try container.encodeIfPresent(currentRound, forKey: .currentRound)
        
        // Handle the bracketData encoding
        if let bracketData = bracketData,
           let jsonData = try? JSONSerialization.data(withJSONObject: bracketData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try container.encode(jsonString, forKey: .bracketData)
        }
        
        try container.encodeIfPresent(registrationStart, forKey: .registrationStart)
        try container.encodeIfPresent(registrationEnd, forKey: .registrationEnd)
        try container.encodeIfPresent(allowLateRegistration, forKey: .allowLateRegistration)
    }
}

class EventRecurrenceConfig: Codable {
    var recurrenceRule: String?
    var recurrenceEnd: Date?
    var parentEventID: String?
    var deletedInstances: [String]?
    
    enum CodingKeys: String, CodingKey {
        case recurrenceRule = "recurrence_rule"
        case recurrenceEnd = "recurrence_end"
        case parentEventID = "parent_event_id"
        case deletedInstances = "deleted_instances"
    }
    
    init(recurrenceRule: String? = nil,
         recurrenceEnd: Date? = nil,
         parentEventID: String? = nil,
         deletedInstances: [String]? = nil) {
        self.recurrenceRule = recurrenceRule
        self.recurrenceEnd = recurrenceEnd
        self.parentEventID = parentEventID
        self.deletedInstances = deletedInstances
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Create date formatter for ISO8601 format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        recurrenceRule = try container.decodeIfPresent(String.self, forKey: .recurrenceRule)
        
        // Handle date decoding with string support
        if let endString = try container.decodeIfPresent(String.self, forKey: .recurrenceEnd),
           let parsedDate = dateFormatter.date(from: endString) {
            recurrenceEnd = parsedDate
        } else if let endInt = try container.decodeIfPresent(Int.self, forKey: .recurrenceEnd) {
            recurrenceEnd = Date(timeIntervalSince1970: TimeInterval(endInt))
        } else {
            recurrenceEnd = try container.decodeIfPresent(Date.self, forKey: .recurrenceEnd)
        }
        
        parentEventID = try container.decodeIfPresent(String.self, forKey: .parentEventID)
        deletedInstances = try container.decodeIfPresent([String].self, forKey: .deletedInstances)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(recurrenceRule, forKey: .recurrenceRule)
        try container.encodeIfPresent(recurrenceEnd, forKey: .recurrenceEnd)
        try container.encodeIfPresent(parentEventID, forKey: .parentEventID)
        try container.encodeIfPresent(deletedInstances, forKey: .deletedInstances)
    }
}


// MARK: - Participant Models
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
    var status: RSVPStatus?
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
         status: RSVPStatus? = nil,
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
        status = try container.decodeIfPresent(RSVPStatus.self, forKey: .status)
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(status, forKey: .status)
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


// MARK: - Team Models
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
    var minTeams: Int32?
    var maxTeams: Int32?
    var maxTeamSize: Int32?
    
    enum CodingKeys: String, CodingKey {
        case hasWaitlist = "has_waitlist"
        case minTeams = "min_teams"
        case maxTeams = "max_teams"
        case maxTeamSize = "max_team_size"
    }
    
    init(hasWaitlist: Bool? = nil,
         minTeams: Int32? = nil,
         maxTeams: Int32? = nil,
         maxTeamSize: Int32? = nil) {
        self.hasWaitlist = hasWaitlist
        self.minTeams = minTeams
        self.maxTeams = maxTeams
        self.maxTeamSize = maxTeamSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasWaitlist = try container.decodeIfPresent(Bool.self, forKey: .hasWaitlist)
        minTeams = try container.decodeIfPresent(Int32.self, forKey: .minTeams)
        maxTeams = try container.decodeIfPresent(Int32.self, forKey: .maxTeams)
        maxTeamSize = try container.decodeIfPresent(Int32.self, forKey: .maxTeamSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hasWaitlist, forKey: .hasWaitlist)
        try container.encodeIfPresent(minTeams, forKey: .minTeams)
        try container.encodeIfPresent(maxTeams, forKey: .maxTeams)
        try container.encodeIfPresent(maxTeamSize, forKey: .maxTeamSize)
    }
}


// MARK: - Event Comment
class EventComment: Codable {
    var id: String
    var user: UserSnippet?
    var text: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case text
        case createdAt = "created_at"
    }
    
    init(id: String,
         user: UserSnippet? = nil,
         text: String,
         createdAt: Date) {
        self.id = id
        self.user = user
        self.text = text
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        text = try container.decode(String.self, forKey: .text)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = try parseDate(from: createdAtString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encode(text, forKey: .text)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

class EventCommentDao: Codable {
    var id: String?
    var userID: String?
    var text: String?
    var eventID: String
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case text
        case eventID = "event_id"
        case createdAt = "created_at"
    }
    
    init(id: String? = nil,
         userID: String? = nil,
         text: String? = nil,
         eventID: String,
         createdAt: Date? = nil) {
        self.id = id
        self.userID = userID
        self.text = text
        self.eventID = eventID
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        eventID = try container.decode(String.self, forKey: .eventID)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(eventID, forKey: .eventID)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}


// MARK: - Extensions
extension Event {
    
    func isCompetition() -> Bool {
        guard let config = self.formatConfig,
              let isCompetition = config.isCompetition else { return false }
        return isCompetition
    }
    
    /// Converts the start time of the event to a human comprehensible string value.
    /// Can either return today, tomorrow, a day of the week, if further than a week away M/d/y.
    /// - Returns: a formatted `String` value of the event's start date
    func timeToString() -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self.startTime) {
            return "Today"
        } else if calendar.isDateInTomorrow(self.startTime) {
            return "Tomorrow"
        } else if calendar.isDate(self.startTime, equalTo: currentDate, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "en_US")
            return formatter.string(from: self.startTime)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "en_US")
            return formatter.string(from: self.startTime)
        }
    }
    
    /// If an event is live this will return the time difference from the start date and now.
    /// If an event is not live then it will return the start date of the event.
    /// - Returns: a formatted `String` of the time difference
    func timeDifferenceToString() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let timeDifference = Int(currentDate.timeIntervalSince(self.startTime))
        
        if timeDifference < 60 {
            return "\(timeDifference) secs"
        } else if timeDifference < 3600 {
            let minutes = timeDifference / 60
            return "\(minutes) mins"
        } else if timeDifference < 86400 * 12 {
            dateFormatter.dateFormat = "h:mm"
            return dateFormatter.string(from: self.startTime) + " mins"
        } else {
            dateFormatter.dateFormat = "d"
            return dateFormatter.string(from: self.startTime) + " days"
        }
    }
    
    /// Returns in string the estimated time to an event's field
    func estimatedTimeToVenue(venue: Venue, _ loc: CLLocationCoordinate2D?) -> String {
        var fieldLocation: [Double] {
            return venue.location.coordinates
        }
        
        guard let location = loc,
              fieldLocation.count > 1 else {
            return "10 min"
        }
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let targetLocation = CLLocation(latitude: fieldLocation[1], longitude: fieldLocation[0])
        let distance = currentLocation.distance(from: targetLocation)
        let speed: CLLocationSpeed = 500 // Assuming a speed of 500 meters/minute
        let timeDifference = distance / speed
        
        if timeDifference < 0 {
            return "1 min"
        }
        
        let timeInMinutes = Int(timeDifference)
        
        if timeInMinutes < 60 {
            return "\(timeInMinutes) min"
        } else {
            let hours = timeInMinutes / 60
            let minutes = timeInMinutes % 60
            let formattedTime = String(format: "%d:%02d min", hours, minutes)
            return formattedTime
        }
    }
    
    func getEventStatus() -> EVENT_STATUS {
        let currentDate = Date()
        if currentDate < self.startTime {
            return .pending
        } else if currentDate >= self.startTime && currentDate < self.stopTime {
            return .live
        } else {
            return .ended
        }
    }
    
    func getStartHourAndMinute() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self.startTime)
    }

    func getStopHourAndMinute() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self.stopTime)
    }
}

extension [Event] {
    
    /// Returns the most recent event for the user
    func mostRecentForUser(uuid: String) -> Event? {
        guard self.count > 0 else {
            return nil
        }
        var filtered = self
            .filter { $0.participants.first(where: { $0.user?.uuid == uuid }) != nil }
            .sorted { ($0.startTime) < ($1.startTime) }
        
        guard filtered.count > 0 else {
            return nil
        }
        
        return filtered.first
    }
    
    /// Returns a filtered array of the events by club ID
    func filterByGroupID(id: String) -> [Event]? {
        guard self.count > 0 else {
            return nil
        }
        
        let filtered = self.filter { $0.organizers.contains(where: { $0.id == id }) }
        guard filtered.count > 0 else {
            return nil
        }
        
        return filtered.sorted { $0.startTime < $1.startTime }
    }
    
    /// Returns an array of Day Group structs that groups events by their start dates
    func eventsGroupedByDay() -> [DayGroup] {
        var groups: [DayGroup] = [DayGroup]();
        self
            .forEach { e in
                let index = groups.firstIndex(where: {
                    areDatesOnSameDay(
                        date1: $0.date,
                        date2: e.startTime
                    )}
                )
                
                if index != nil {
                    groups[index!].events.append(e)
                    return
                } else {
                    let newGroup = DayGroup(date: e.startTime, events: [e])
                    groups.append(newGroup)
                    return
                }
            }
        
        var sorted = groups
            .sorted { (group1: DayGroup, group2: DayGroup) in
                if areDatesOnSameDay(date1: group1.date, date2: group2.date) {
                    // If dates are on the same day, prioritize item1
                    return true
                } else {
                    // If dates are not on the same day, sort by timestamp
                    return group1.date < group2.date
                }
            }
        for i in 0..<sorted.count {
            sorted[i].events = sorted[i].events.sorted { event1, event2 in
                return event1.startTime < event2.startTime
            }
        }
        
        return sorted
    }
}
