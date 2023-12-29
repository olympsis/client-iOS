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
    let poster: String?
    var organizers: [Organizer]?
    var field: FieldDescriptor?
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
    var data: EventData?
    let createdAt: Int?
    var externalLink: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poster
        case organizers
        case field
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
        case data
        case createdAt = "created_at"
        case externalLink = "external_link"
    }
    
    init(id: String?=nil, type: String, poster: String?=nil, organizers: [Organizer]?=nil, field: FieldDescriptor?=nil, imageURL: String?=nil, title: String?=nil, body: String?=nil, sport: String?=nil, level: Int?=nil, startTime: Int?=nil, actualStartTime: Int?=nil, stopTime: Int?=nil, actualStopTime: Int?=nil, minParticipants: Int?=nil, maxParticipants: Int?=nil, participants: [Participant]?=nil, visibility: String?=nil, data: EventData?=nil, createdAt: Int?=nil, externalLink: String?=nil) {
        self.id = id
        self.type = type
        self.poster = poster
        self.organizers = organizers
        self.field = field
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
        self.data = data
        self.createdAt = createdAt
        self.externalLink = externalLink
    }
}

struct Organizer: Codable, Identifiable {
    let type: String
    let id: String
}

struct FieldDescriptor: Codable {
    let type: String
    let id: String?
    let location: GeoJSON?
}

struct Participant: Codable, Identifiable, Hashable {
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    let uuid: String
    var data: UserData?
    let status: String
    let createdAt: Int?
    
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
    let field: Field?
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
    func estimatedTimeToField(_ loc: CLLocationCoordinate2D?) -> String {
        var fieldLocation: [Double] {
            guard let data = self.data,
                  let field = data.field else {
                return [0, 0]
            }
            return field.location.coordinates
        }
        
        guard let location = loc else {
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
        var filtered = self.filter{ $0.participants?.first(where: { $0.uuid == uuid }) != nil }
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
