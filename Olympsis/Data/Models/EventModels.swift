//
//  EventModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/31/23.
//

import SwiftUI
import Foundation
import CoreLocation

class Event: Decodable, Identifiable, ObservableObject {
    
    let id: String
    let type: EVENT_TYPES
    let poster: UserSnippet?
    var organizers: [Organizer]?
    var venues: [VenueDescriptor]?
    var imageURL: String?
    var title: String
    var body: String?
    let sports: [String]
    var level: EVENT_SKILL_LEVELS
    @Published var startTime: Int
    @Published var stopTime: Int
    @Published var minParticipants: Int?
    @Published var maxParticipants: Int?
    @Published var participants: [Participant]?
    var visibility: EVENT_VISIBILITY_TYPES
    let createdAt: Int?
    var externalLink: String?
    var isSensitive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poster
        case organizers
        case venue
        case venues
        case imageURL = "image_url"
        case title
        case body
        case sports
        case level
        case startTime = "start_time"
        case actualStartTime = "actual_start_time"
        case stopTime = "stop_time"
        case actualStopTime = "actual_stop_time"
        case minParticipants = "min_participants"
        case maxParticipants = "max_participants"
        case participants
        case visibility
        case clubs = "clubs"
        case organizations = "organizations"
        case createdAt = "created_at"
        case externalLink = "external_link"
        case isSensitive = "is_sensitive"
    }
    
    init(id: String, type: EVENT_TYPES, poster: UserSnippet?=nil, organizers: [Organizer]?=nil, venues: [VenueDescriptor]?=nil, imageURL: String?=nil, title: String, body: String?=nil, sports: [String], level: EVENT_SKILL_LEVELS?=nil, startTime: Int, stopTime: Int, minParticipants: Int?=nil, maxParticipants: Int?=nil, participants: [Participant]?=nil, visibility: EVENT_VISIBILITY_TYPES, createdAt: Int?=nil, isSensitive: Bool?=nil, externalLink: String?=nil) {
        self.id = id
        self.type = type
        self.poster = poster
        self.organizers = organizers
        self.venues = venues
        self.imageURL = imageURL
        self.title = title
        self.body = body
        self.sports = sports
        self.level = level ?? .All
        self.startTime = startTime
        self.stopTime = stopTime
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.participants = participants
        self.visibility = visibility
        self.createdAt = createdAt
        self.externalLink = externalLink
        self.isSensitive = isSensitive
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required properties
        self.id = try container.decode(String.self, forKey: .id)
        
        // Decode type and convert from Int to EVENT_TYPES
        let typeInt = try container.decode(Int.self, forKey: .type)
        self.type = numberToEventType(number: typeInt)
        
        // Decode optional properties
        self.poster = try container.decodeIfPresent(UserSnippet.self, forKey: .poster)
        self.organizers = try container.decodeIfPresent([Organizer].self, forKey: .organizers)
        
        // Handle venues with backwards compatibility
        if let singleVenue = try container.decodeIfPresent(VenueDescriptor.self, forKey: .venue) {
            self.venues = [singleVenue]
        } else {
            self.venues = try container.decodeIfPresent([VenueDescriptor].self, forKey: .venues)
        }
        
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.sports = try container.decodeIfPresent([String].self, forKey: .sports) ?? []
        
        // Decode level and convert from Int to EVENT_SKILL_LEVELS
        if let levelInt = try container.decodeIfPresent(Int.self, forKey: .level) {
            self.level = numberToEventSkillLEvel(number: levelInt)
        } else {
            self.level = .All
        }
        
        // Decode @Published properties
        self.startTime = try container.decode(Int.self, forKey: .startTime)
        self.stopTime = try container.decode(Int.self, forKey: .stopTime)
        self.minParticipants = try container.decodeIfPresent(Int.self, forKey: .minParticipants)
        self.maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
        self.participants = try container.decodeIfPresent([Participant].self, forKey: .participants)
        
        // Decode remaining optional properties
        self.visibility = numberToEventVisibilityType(try container.decodeIfPresent(Int.self, forKey: .visibility) ?? 0)
        self.createdAt = try container.decodeIfPresent(Int.self, forKey: .createdAt)
        self.externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        self.isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
    }
    
    func update(_ event: Event) {
        self.title = event.title
        self.body = event.body
        self.level = event.level
        self.venues = event.venues
        self.participants = event.participants
        self.startTime = event.startTime
        self.stopTime = event.stopTime
        self.imageURL = event.imageURL
        self.minParticipants = event.minParticipants
        self.maxParticipants = event.maxParticipants
        self.visibility = event.visibility
        self.externalLink = event.externalLink
        self.organizers = event.organizers
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

struct Participant: Decodable, Identifiable, Hashable {
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var user: UserSnippet?
    let status: EVENT_RSVP_STATUS
    let createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case status
        case createdAt = "created_at"
    }
    
    init (id: String, user: UserSnippet?=nil, status: EVENT_RSVP_STATUS, createdAt: Int?=nil) {
        self.id = id
        self.user = user
        self.status = status
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        self.createdAt = try container.decodeIfPresent(Int.self, forKey: .createdAt)
        self.status = numberToEventRSVPStatus(try container.decode(Int.self, forKey: .status))
    }
}

struct EventData: Decodable {
    let poster: UserData?
    let field: Venue?
    let clubs: [Club]?
    let organizations: [Organization]?
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

extension Event {
    
    /// Converts the start time of the event to a human comprehensible string value.
    /// Can either return today, tomorrow, a day of the week, if futher than a week away M/d/y.
    /// - Returns: a formated `String` value of the event's start date
    func timeToString() -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        let timestamp = TimeInterval(self.startTime)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_US")
        
        if calendar.isDateInToday(Date(timeIntervalSince1970: timestamp)) {
            return "Today"
        } else if calendar.isDateInTomorrow(Date(timeIntervalSince1970: timestamp)) {
            return "Tomorrow"
        } else if calendar.isDate(Date(timeIntervalSince1970: timestamp), equalTo: currentDate, toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: Date(timeIntervalSince1970: timestamp))
        } else if calendar.isDate(Date(timeIntervalSince1970: timestamp), equalTo: currentDate, toGranularity: .year) {
            return formatter.string(from: Date(timeIntervalSince1970: timestamp))
        } else {
            return formatter.string(from: Date(timeIntervalSince1970: timestamp))
        }
    }
    
    /// If an event is live this will return the time difference from the start date and now.
    /// If an event is not live then it will return the start date of the event.
    /// - Returns: a formatted `String` of the time difference
    func timeDifferenceToString() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(self.startTime))
        let timeDifference = Int(currentDate.timeIntervalSince1970 - TimeInterval(self.startTime))
        
        if timeDifference < 60 {
            return "\(timeDifference) secs"
        } else if timeDifference < 3600 {
            let minutes = timeDifference / 60
            return "\(minutes) mins"
        } else if timeDifference < 86400 * 12 {
            dateFormatter.dateFormat = "h:mm"
            return dateFormatter.string(from: date) + " mins";
        } else {
            dateFormatter.dateFormat = "d"
            return dateFormatter.string(from: date) + " days";
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
        let currentDate = Date().timeIntervalSince1970
        if (currentDate < TimeInterval(self.startTime)) {
            return .pending
        } else if (currentDate >= TimeInterval(self.startTime) && currentDate < TimeInterval(self.stopTime)) {
            return .live
        } else {
            return .ended
        }
    }
    
    func getStartHourAndMinute() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.startTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    func getStopHourAndMinute() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.stopTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

extension [Event] {
    
    /// Returns the most recent event for the user
    func mostRecentForUser(uuid: String) -> Event? {
        guard self.count > 0 else {
            return nil
        }
        var filtered = self.filter{ $0.participants?.first(where: { $0.user?.uuid == uuid }) != nil }
        filtered = filtered.sorted { ($0.startTime) < ($1.startTime) }
        
        guard filtered.count > 0 else {
            return nil
        }
        
        return filtered[0]
    }
    
    /// Returns a filtered array of the events by club ID
    func filterByGroupID(id: String) -> [Event]? {
        guard self.count > 0 else {
            return nil
        }
        
        let filtered = self.filter { $0.organizers?.contains(where: { $0.id == id }) ?? false }
        guard filtered.count > 0 else {
            return nil
        }
        
        return filtered.sorted { $0.startTime < $1.startTime }
    }
}

class EventDao: Codable, Identifiable, ObservableObject {
    
    let type: EVENT_TYPES?
    let poster: String?
    var organizers: [Organizer]?
    var venues: [VenueDescriptor]?
    var imageURL: String?
    var title: String?
    var body: String?
    let sports: [String]?
    var level: EVENT_SKILL_LEVELS?
    var startTime: Int?
    var stopTime: Int?
    var minParticipants: Int?
    var maxParticipants: Int?
    var participants: [Participant]?
    var visibility: EVENT_VISIBILITY_TYPES?
    let createdAt: Int?
    var externalLink: String?
    var isSensitive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type
        case poster
        case organizers
        case venues
        case imageURL = "image_url"
        case title
        case body
        case sports
        case level
        case startTime = "start_time"
        case actualStartTime = "actual_start_time"
        case stopTime = "stop_time"
        case actualStopTime = "actual_stop_time"
        case minParticipants = "min_participants"
        case maxParticipants = "max_participants"
        case participants
        case visibility
        case isSensitive = "is_sensitive"
        case createdAt = "created_at"
        case externalLink = "external_link"
    }
    
    init(type: EVENT_TYPES?=nil, poster: String?=nil, organizers: [Organizer]?=nil, venues: [VenueDescriptor]?=nil, imageURL: String?=nil, title: String?=nil, body: String?=nil, sports: [String]?=nil, level: EVENT_SKILL_LEVELS?=nil, startTime: Int?=nil, stopTime: Int?=nil, minParticipants: Int?=nil, maxParticipants: Int?=nil, participants: [Participant]?=nil, visibility: EVENT_VISIBILITY_TYPES?=nil, createdAt: Int?=nil, isSensitive: Bool?=nil, externalLink: String?=nil) {
        self.type = type
        self.poster = poster
        self.organizers = organizers
        self.venues = venues
        self.imageURL = imageURL
        self.title = title
        self.body = body
        self.sports = sports
        self.level = level
        self.startTime = startTime
        self.stopTime = stopTime
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.participants = participants
        self.visibility = visibility
        self.createdAt = createdAt
        self.isSensitive = isSensitive
        self.externalLink = externalLink
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = numberToEventType(number: try container.decodeIfPresent(Int.self, forKey: .type) ?? 0)
        self.poster = try container.decodeIfPresent(String.self, forKey: .poster)
        self.organizers = try container.decodeIfPresent([Organizer].self, forKey: .organizers)
        self.venues = try container.decodeIfPresent([VenueDescriptor].self, forKey: .venues)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.sports = try container.decodeIfPresent([String].self, forKey: .sports)
        self.level = numberToEventSkillLEvel(number: try container.decodeIfPresent(Int.self, forKey: .level) ?? 0)
        self.startTime = try container.decodeIfPresent(Int.self, forKey: .startTime)
        self.stopTime = try container.decodeIfPresent(Int.self, forKey: .stopTime)
        self.minParticipants = try container.decodeIfPresent(Int.self, forKey: .minParticipants)
        self.maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
        self.visibility = numberToEventVisibilityType(try container.decodeIfPresent(Int.self, forKey: .visibility) ?? 0)
        
        self.isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
        self.externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        
        self.createdAt = try container.decodeIfPresent(Int.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type?.toInt(), forKey: .type)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(organizers, forKey: .organizers)
        try container.encodeIfPresent(venues, forKey: .venues)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(sports, forKey: .sports)
        try container.encodeIfPresent(level?.toInt(), forKey: .level)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(stopTime, forKey: .stopTime)
        try container.encodeIfPresent(minParticipants, forKey: .minParticipants)
        try container.encodeIfPresent(maxParticipants, forKey: .maxParticipants)
//        try container.encodeIfPresent(participants, forKey: .participants) We don't do anything with that here
        try container.encodeIfPresent(visibility?.toInt(), forKey: .visibility)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(isSensitive, forKey: .isSensitive)
        try container.encodeIfPresent(externalLink, forKey: .externalLink)
    }
}

struct NewEventDao: Codable {
    var event: EventDao
    var includeHost: Bool
    var reccurenceOptions: EventRecurrenceOptions?
    
    enum CodingKeys: String, CodingKey {
        case event
        case includeHost = "include_host"
        case reccurenceOptions = "recurrence_options"
    }
}

class EventRecurrenceOptions: Codable {
    var pattern: String
    var endTime: Int
    var interval: Int
    
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


struct DayGroup: Identifiable {
    let id = UUID()
    let timestamp: Int
    var events: [Event]
    
    var dayInString: String {
        return events[0].timeToString()
    }
}
