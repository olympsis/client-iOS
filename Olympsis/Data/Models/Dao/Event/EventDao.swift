//
//  NewEventDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/26/22.
//

import Foundation

class EventDao: Dao {
    let title:              String?
    let body:               String?
    let clubId:             String?
    let fieldId:            String?
    let imageURL:           String?
    let sport:              String?
    let startTime:          Int?
    let maxParticipants:    Int?
    let level:              Int?
    let status:             String?
    let actualStartTime:    Int?
    let stopTime:           Int?
    let actualStopTime:    Int?

    init(title: String?=nil, body: String?=nil, clubId: String?=nil, fieldId: String?=nil, imageURL: String?=nil, sport: String?=nil, startTime: Int?=nil, maxParticipants: Int?=nil, level: Int?=nil, actualSTime: Int? = nil, stopTime: Int? = nil, actualStopTime: Int? = nil, status: String?=nil){
        self.title = title
        self.body = body
        self.clubId = clubId
        self.fieldId = fieldId
        self.imageURL = imageURL
        self.sport = sport
        self.startTime = startTime
        self.maxParticipants = maxParticipants
        self.level = level
        self.actualStartTime = actualSTime
        self.stopTime = stopTime
        self.status = status
        self.actualStopTime = actualStopTime
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(clubId, forKey: .clubId)
        try container.encode(fieldId, forKey: .fieldId)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(sport, forKey: .sport)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(maxParticipants, forKey: .maxParticipants)
        try container.encode(status, forKey: .status)
        try container.encode(level, forKey: .level)
        if let ast = actualStartTime {
            try container.encode(ast, forKey: .actualStartTime)
        }
        if let st = stopTime {
            try container.encode(st, forKey: .stopTime)
        }
        if let actualStopTime = actualStopTime {
            try container.encode(actualStopTime, forKey: .actualStopTime)
        }
        try container.encode(status, forKey: .status)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case clubId
        case fieldId
        case imageURL
        case sport
        case startTime = "start_time"
        case maxParticipants = "max_participants"
        case level
        case actualStartTime = "actual_start_time"
        case stopTime = "stop_time"
        case actualStopTime = "actual_stop_time"
        case status
    }
}
