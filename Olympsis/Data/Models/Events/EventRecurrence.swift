//
//  Recurrence.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

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
        try container.encode(endTime.ISO8601Format(), forKey: .endTime)
        try container.encode(interval, forKey: .interval)
    }
    
    enum CodingKeys: String, CodingKey {
        case pattern
        case endTime = "end_time"
        case interval
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
        recurrenceRule = try container.decodeIfPresent(String.self, forKey: .recurrenceRule)
        
        // Handle date decoding with string support
        if let endString = try container.decodeIfPresent(String.self, forKey: .recurrenceEnd) {
            recurrenceEnd = try parseDate(from: endString)
        }
        
        parentEventID = try container.decodeIfPresent(String.self, forKey: .parentEventID)
        deletedInstances = try container.decodeIfPresent([String].self, forKey: .deletedInstances)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(recurrenceRule, forKey: .recurrenceRule)
        try container.encodeIfPresent(recurrenceEnd?.ISO8601Format(), forKey: .recurrenceEnd)
        try container.encodeIfPresent(parentEventID, forKey: .parentEventID)
        try container.encodeIfPresent(deletedInstances, forKey: .deletedInstances)
    }
}
