//
//  Event.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation
import CoreLocation

@Observable
class Event: Codable, Identifiable, Hashable {
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

    var config: EventConfig?
    var formatConfig: EventFormatConfig?
    
    var startTime: Date
    var stopTime: Date
    
    var participants: [Participant]
    var participantsWaitlist: [Participant]
    var participantsConfig: ParticipantsConfig?
    
    var teams: [Team]
    var teamsWaitlist: [Team]
    var teamsConfig: TeamsConfig?
    
    var comments: [EventComment]
    
    var visibility: EVENT_VISIBILITY_TYPES
    var externalLinks: [EventLink]?
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
        
        case mediaURL = "media_url"
        case mediaType = "media_type"
        
        case title
        case body
        case tags
        case sports
        
        case config
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
        case externalLinks = "external_links"
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
         config: EventConfig? = nil,
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
         externalLinks: [EventLink]? = nil,
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
        
        self.config = config
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
        self.externalLinks = externalLinks
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
        
        venues = try container.decodeIfPresent([VenueDescriptor].self, forKey: .venues) ?? []
        
        // Decode media properties with conversion
        mediaURL = try container.decode(String.self, forKey: .mediaURL)
        let mediaTypeRawValue = try container.decode(String.self, forKey: .mediaType)
        mediaType = MEDIA_TYPES(rawValue: mediaTypeRawValue.lowercased()) ?? .image
        
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        sports = try container.decodeIfPresent([String].self, forKey: .sports) ?? []
        
        config = try container.decodeIfPresent(EventConfig.self, forKey: .config)
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
        
        visibility = try container.decode(EVENT_VISIBILITY_TYPES.self, forKey: .visibility)
        
        externalLinks = try container.decodeIfPresent([EventLink].self, forKey: .externalLinks)
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encode(organizers, forKey: .organizers)
        try container.encode(venues, forKey: .venues)

        try container.encode(mediaURL, forKey: .mediaURL)
        // Encode as lowercase string to match what the API expects
        try container.encode(mediaType.rawValue, forKey: .mediaType)

        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(tags, forKey: .tags)
        try container.encode(sports, forKey: .sports)

        try container.encodeIfPresent(config, forKey: .config)
        try container.encodeIfPresent(formatConfig, forKey: .formatConfig)

        // Encode dates as ISO8601 strings to match the decoder's expected format
        try container.encode(startTime.ISO8601Format(), forKey: .startTime)
        try container.encode(stopTime.ISO8601Format(), forKey: .stopTime)

        try container.encode(participants, forKey: .participants)
        try container.encode(participantsWaitlist, forKey: .participantsWaitlist)
        try container.encodeIfPresent(participantsConfig, forKey: .participantsConfig)

        try container.encode(teams, forKey: .teams)
        try container.encode(teamsWaitlist, forKey: .teamsWaitlist)
        try container.encodeIfPresent(teamsConfig, forKey: .teamsConfig)

        try container.encode(comments, forKey: .comments)

        try container.encode(visibility, forKey: .visibility)
        try container.encodeIfPresent(externalLinks, forKey: .externalLinks)
        try container.encode(isSensitive, forKey: .isSensitive)

        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
        try container.encodeIfPresent(updatedAt?.ISO8601Format(), forKey: .updatedAt)
        try container.encodeIfPresent(canceledAt?.ISO8601Format(), forKey: .canceledAt)

        try container.encodeIfPresent(recurrenceConfig, forKey: .recurrenceConfig)
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
        self.externalLinks = event.externalLinks
        self.organizers = event.organizers
        self.tags = event.tags
        self.sports = event.sports
        self.config = config
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

/// Represents an external link attached to an event, matching the server's EventLink struct.
struct EventLink: Codable, Hashable, Identifiable {
    var id: String { "\(title)_\(url)" }
    var title: String
    var url: String
}

struct EventConfig: Codable {
    var hidePoster: Bool? = nil
    
    // Hide Pre-RSVP
    var hideLocation: Bool? = nil
    
    enum CodingKeys: String, CodingKey {
        case hidePoster = "hide_poster"
        case hideLocation = "hide_location"
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
    var config: EventConfig?
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
    var externalLinks: [EventLink]?
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
        case config
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
        case externalLinks = "external_links"
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
        config: EventConfig? = nil,
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
        externalLinks: [EventLink]? = nil,
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
        self.config = config
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
        self.externalLinks = externalLinks
        self.recurrenceConfig = recurrenceConfig
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.poster = try container.decodeIfPresent(String.self, forKey: .poster)
        self.organizers = try container.decodeIfPresent([Organizer].self, forKey: .organizers)
        self.venues = try container.decodeIfPresent([VenueDescriptor].self, forKey: .venues)
        self.mediaURL = try container.decodeIfPresent(String.self, forKey: .mediaURL)
        
        // Decode mediaType — API sends uppercase (e.g. "IMAGE")
        if let mediaTypeRaw = try container.decodeIfPresent(String.self, forKey: .mediaType) {
            self.mediaType = MEDIA_TYPES(rawValue: mediaTypeRaw.lowercased())
        } else {
            self.mediaType = nil
        }
        
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.sports = try container.decodeIfPresent([String].self, forKey: .sports)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
        self.config = try container.decodeIfPresent(EventConfig.self, forKey: .config)
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
        
        self.visibility = try container.decodeIfPresent(EVENT_VISIBILITY_TYPES.self, forKey: .visibility)
        
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
        self.externalLinks = try container.decodeIfPresent([EventLink].self, forKey: .externalLinks)
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
        try container.encodeIfPresent(config, forKey: .config)
        try container.encodeIfPresent(formatConfig, forKey: .formatConfig)
        try container.encodeIfPresent(startTime?.ISO8601Format(), forKey: .startTime)
        try container.encodeIfPresent(stopTime?.ISO8601Format(), forKey: .stopTime)
        try container.encodeIfPresent(participantsConfig, forKey: .participantsConfig)
        try container.encodeIfPresent(participants, forKey: .participants)
        try container.encodeIfPresent(teamsConfig, forKey: .teamsConfig)
        try container.encodeIfPresent(teams, forKey: .teams)
        try container.encodeIfPresent(visibility?.rawValue, forKey: .visibility)
        try container.encodeIfPresent(createdAt?.ISO8601Format(), forKey: .createdAt)
        try container.encodeIfPresent(updatedAt?.ISO8601Format(), forKey: .updatedAt)
        try container.encodeIfPresent(canceledAt?.ISO8601Format(), forKey: .canceledAt)
        try container.encodeIfPresent(isSensitive, forKey: .isSensitive)
        try container.encodeIfPresent(externalLinks, forKey: .externalLinks)
        try container.encodeIfPresent(recurrenceConfig, forKey: .recurrenceConfig)
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
        case recurrence
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
            return String(localized: "day-today", table: "General")
        } else if calendar.isDateInTomorrow(self.startTime) {
            return String(localized: "day-tomorrow", table: "General")
        } else if calendar.isDate(self.startTime, equalTo: currentDate, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: Locale.current.identifier)
            return formatter.string(from: self.startTime)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: Locale.current.identifier)
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

    /// Pin coordinate derived from the first `VenueDescriptor` that carries
    /// an embedded GeoJSON Point. Returns `nil` when no descriptor ships a
    /// point (e.g. location-hidden events). Reads only the embedded snapshot
    /// — no session/venue-cache lookup — so it's safe to call from model
    /// code and produces a stable value for series matching.
    var primaryCoordinate: CLLocationCoordinate2D? {
        for descriptor in venues {
            let coords = descriptor.location?.coordinates ?? []
            if coords.count >= 2 {
                return CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
            }
        }
        return nil
    }

    /// Stable key for the recurring series this event belongs to, or `nil`
    /// if it can't be placed in one (no recurrence link *and* no coordinate
    /// to match scraped siblings against).
    ///
    /// Two distinct flavors of "recurring" collapse onto the same key:
    ///   1. **Backend-linked** — events that share a
    ///      `recurrenceConfig.parentEventID`. The series root has no parent
    ///      id, so it treats its own `id` as the root.
    ///   2. **Scraped** — events our data scraper ingested as independent
    ///      rows but that are clearly the same recurring event: identical
    ///      title hosted at the exact same coordinates, only the date
    ///      differs. We re-stitch those here by `title + coordinate`.
    ///
    /// Coordinates are rounded to 5 decimal places (~1.1 m) so sub-meter
    /// floating-point noise in the feed doesn't split one venue into
    /// several series, while still being effectively "exact".
    var recurringSeriesKey: String? {
        if let config = recurrenceConfig {
            return "linked:\(config.parentEventID ?? id)"
        }
        guard let coord = primaryCoordinate else { return nil }
        let lat = (coord.latitude * 1e5).rounded() / 1e5
        let lng = (coord.longitude * 1e5).rounded() / 1e5
        let name = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return "scraped:\(name)|\(lat)|\(lng)"
    }
}

extension [Event] {

    /// Every event that shares `event`'s recurring-series key, including
    /// `event` itself. Returns just `[event]` when the event isn't part of
    /// a series (so callers can treat "not recurring" as a single-element
    /// result). See `Event.recurringSeriesKey` for what counts as a series.
    func recurringSeries(of event: Event) -> [Event] {
        guard let key = event.recurringSeriesKey else { return [event] }
        return filter { $0.recurringSeriesKey == key }
    }

    /// The occurrence to surface for a series: the soonest one that hasn't
    /// started yet. Falls back to the most recent past occurrence only when
    /// every occurrence is already over (we don't expect past events on the
    /// map, but this keeps the helper from returning `nil` for any
    /// non-empty series).
    func soonestUpcoming() -> Event? {
        let now = Date()
        let sorted = self.sorted { $0.startTime < $1.startTime }
        return sorted.first(where: { $0.startTime >= now }) ?? sorted.last
    }
}

extension [Event] {
    
    /// Returns the most recent event for the user
    func mostRecentForUser(userID: String) -> Event? {
        return self
            .filter { $0.participants.first(where: { $0.user?.userID == userID }) != nil }
            .sorted { $0.startTime < $1.startTime }
            .first
    }
    
    /// Returns all of the events that the user has RSVPed to
    func rsvpedEvents(userID: String) -> [Event] {
        return self
            .filter { $0.participants.first(where: { $0.user?.userID == userID }) != nil }
            .sorted { $0.startTime < $1.startTime }
    }
    
    /// Returns a filtered array of the events by club ID
    func filterByGroupID(id: String) -> [Event] {
        return self
            .filter { $0.organizers.contains(where: { $0.id == id }) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    /// Returns an array of Day Group structs that groups events by their start dates
    func eventsGroupedByDay() -> [DayGroup] {
        var groups: [DayGroup] = [DayGroup]();
        self
            .sorted { $0.startTime < $1.startTime }
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
