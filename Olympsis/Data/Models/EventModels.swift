//
//  EventModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/31/23.
//

import SwiftUI
import Foundation
import CoreLocation

class Event: Codable, Identifiable, ObservableObject {
    
    let id: String?
    let type: String?
    let poster: UserSnippet?
    @Published var organizers: [Organizer]?
    var venue: VenueDescriptor?
    @Published var imageURL: String?
    @Published var title: String?
    @Published var body: String?
    let sport: String?
    @Published var level: Int?
    @Published var startTime: Int?
    @Published var actualStartTime: Int?
    @Published var stopTime: Int?
    @Published var actualStopTime: Int?
    @Published var minParticipants: Int?
    @Published var maxParticipants: Int?
    @Published var participants: [Participant]?
    @Published var visibility: String?
    @Published var clubs: [ClubSnippet]?
    @Published var organizations: [OrgSnippet]?
    let fieldData: Venue?
    let createdAt: Int?
    @Published var externalLink: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poster
        case organizers
        case venue
        case imageURL = "image_url"
        case title
        case body
        case sport
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
        case fieldData = "field_data"
        case createdAt = "created_at"
        case externalLink = "external_link"
    }
    
    init(id: String?=nil, type: String, poster: UserSnippet?=nil, organizers: [Organizer]?=nil, venue: VenueDescriptor?=nil, imageURL: String?=nil, title: String?=nil, body: String?=nil, sport: String?=nil, level: Int?=nil, startTime: Int?=nil, actualStartTime: Int?=nil, stopTime: Int?=nil, actualStopTime: Int?=nil, minParticipants: Int?=nil, maxParticipants: Int?=nil, participants: [Participant]?=nil, visibility: String?=nil, createdAt: Int?=nil, externalLink: String?=nil, clubs: [ClubSnippet]?=nil, organizations: [OrgSnippet]?=nil, fieldData: Venue?=nil) {
        self.id = id
        self.type = type
        self.poster = poster
        self.organizers = organizers
        self.venue = venue
        self.imageURL = imageURL
        self.title = title
        self.body = body
        self.sport = sport
        self.level = level
        self.startTime = startTime
        self.actualStartTime = actualStartTime
        self.stopTime = stopTime
        self.actualStopTime = actualStopTime
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.participants = participants
        self.visibility = visibility
        self.clubs = clubs
        self.organizations = organizations
        self.fieldData = fieldData
        self.createdAt = createdAt
        self.externalLink = externalLink
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.poster = try container.decodeIfPresent(UserSnippet.self, forKey: .poster)
        self.organizers = try container.decodeIfPresent([Organizer].self, forKey: .organizers)
        self.venue = try container.decodeIfPresent(VenueDescriptor.self, forKey: .venue)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.sport = try container.decodeIfPresent(String.self, forKey: .sport)
        self.level = try container.decodeIfPresent(Int.self, forKey: .level)
        self.startTime = try container.decodeIfPresent(Int.self, forKey: .startTime)
        self.actualStartTime = try container.decodeIfPresent(Int.self, forKey: .actualStartTime)
        self.stopTime = try container.decodeIfPresent(Int.self, forKey: .stopTime)
        self.actualStopTime = try container.decodeIfPresent(Int.self, forKey: .actualStopTime)
        self.minParticipants = try container.decodeIfPresent(Int.self, forKey: .minParticipants)
        self.maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
        self.participants = try container.decodeIfPresent([Participant].self, forKey: .participants)
        self.visibility = try container.decodeIfPresent(String.self, forKey: .visibility)
        self.clubs = try container.decodeIfPresent([ClubSnippet].self, forKey: .clubs)
        self.organizations = try container.decodeIfPresent([OrgSnippet].self, forKey: .organizations)
        self.fieldData = try container.decodeIfPresent(Venue.self, forKey: .fieldData)
        self.createdAt = try container.decodeIfPresent(Int.self, forKey: .createdAt)
        self.externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(organizers, forKey: .organizers)
        try container.encodeIfPresent(venue, forKey: .venue)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(sport, forKey: .sport)
        try container.encodeIfPresent(level, forKey: .level)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(actualStartTime, forKey: .actualStartTime)
        try container.encodeIfPresent(stopTime, forKey: .stopTime)
        try container.encodeIfPresent(actualStopTime, forKey: .actualStopTime)
        try container.encodeIfPresent(minParticipants, forKey: .minParticipants)
        try container.encodeIfPresent(maxParticipants, forKey: .maxParticipants)
        try container.encodeIfPresent(participants, forKey: .participants)
        try container.encodeIfPresent(visibility, forKey: .visibility)
        try container.encodeIfPresent(clubs, forKey: .clubs)
        try container.encodeIfPresent(organizations, forKey: .organizations)
        try container.encodeIfPresent(fieldData, forKey: .fieldData)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(externalLink, forKey: .externalLink)
    }
    
    func update(_ event: Event) {
        self.title = event.title
        self.body = event.body
        self.level = event.level
        self.venue = event.venue
        self.participants = event.participants
        self.startTime = event.startTime
        self.actualStartTime = event.actualStartTime
        self.stopTime = event.actualStopTime
        self.actualStopTime = event.actualStopTime
        self.imageURL = event.imageURL
        self.minParticipants = event.minParticipants
        self.maxParticipants = event.maxParticipants
        self.visibility = event.visibility
        self.clubs = event.clubs
        self.organizations = event.organizations
        self.externalLink = event.externalLink
        self.organizers = event.organizers
    }
}

struct Organizer: Codable, Identifiable {
    let type: String
    let id: String
}

struct VenueDescriptor: Codable {
    let type: String
    let id: String?
    var name: String?
    var location: GeoJSON?
    
    init(type: String, id: String?=nil, name: String?=nil, location: GeoJSON?=nil) {
        self.type = type
        self.id = id
        self.name = name
        self.location = location
    }
    
    func isInternal() -> Bool {
        return self.type == "internal" ? true : false
    }
}

struct Participant: Codable, Identifiable, Hashable {
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var user: UserSnippet?
    let status: String
    let createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case status
        case createdAt = "created_at"
    }
}

struct EventData: Codable {
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
        guard let eventStartTime = self.startTime else {
            return "0/0/0"
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let timestamp = TimeInterval(eventStartTime)
        
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
        guard let eventStartTime = self.startTime else {
            return "00:00 am"
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(eventStartTime))
        
        // if this event has started move on if not return the formatted start time
        guard let actualStartTime = self.actualStartTime else {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: date)
        }
        
        let timeDifference = Int(currentDate.timeIntervalSince1970 - TimeInterval(actualStartTime))
        
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
}

extension [Event] {
    
    /// Returns the most recent event for the user
    func mostRecentForUser(uuid: String) -> Event? {
        guard self.count > 0 else {
            return nil
        }
        var filtered = self.filter{ $0.participants?.first(where: { $0.user?.uuid == uuid }) != nil }
        filtered = filtered.sorted { ($0.startTime ?? 0) < ($1.startTime ?? 0) }
        
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
        
        return filtered.sorted { $0.startTime! < $1.startTime! }
    }
}

class EventDao: Codable, Identifiable, ObservableObject {
    
    let type: String?
    let poster: String?
    var organizers: [Organizer]?
    var venue: VenueDescriptor?
    var imageURL: String?
    var title: String?
    var body: String?
    let sport: String?
    var level: Int?
    var startTime: Int?
    var actualStartTime: Int?
    var stopTime: Int?
    var actualStopTime: Int?
    var minParticipants: Int?
    var maxParticipants: Int?
    var participants: [Participant]?
    var visibility: String?
    let createdAt: Int?
    var externalLink: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case poster
        case organizers
        case venue
        case imageURL = "image_url"
        case title
        case body
        case sport
        case level
        case startTime = "start_time"
        case actualStartTime = "actual_start_time"
        case stopTime = "stop_time"
        case actualStopTime = "actual_stop_time"
        case minParticipants = "min_participants"
        case maxParticipants = "max_participants"
        case participants
        case visibility
        case createdAt = "created_at"
        case externalLink = "external_link"
    }
    
    init(type: String? = EVENT_TYPES.PickUp.rawValue, poster: String?=nil, organizers: [Organizer]?=nil, venue: VenueDescriptor?=nil, imageURL: String?=nil, title: String?=nil, body: String?=nil, sport: String?=nil, level: Int?=nil, startTime: Int?=nil, actualStartTime: Int?=nil, stopTime: Int?=nil, actualStopTime: Int?=nil, minParticipants: Int?=nil, maxParticipants: Int?=nil, participants: [Participant]?=nil, visibility: String?=nil, createdAt: Int?=nil, externalLink: String?=nil) {
        self.type = type
        self.poster = poster
        self.organizers = organizers
        self.venue = venue
        self.imageURL = imageURL
        self.title = title
        self.body = body
        self.sport = sport
        self.level = level
        self.startTime = startTime
        self.actualStartTime = actualStartTime
        self.stopTime = stopTime
        self.actualStopTime = actualStopTime
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.participants = participants
        self.visibility = visibility
        self.createdAt = createdAt
        self.externalLink = externalLink
    }
}
