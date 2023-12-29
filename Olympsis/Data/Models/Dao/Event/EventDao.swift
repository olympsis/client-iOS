//
//  EventDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/26/22.
//

import Foundation

class EventDao: Dao {
    let title:              String?
    let body:               String?
    let imageURL:           String?
    
    let level:              Int?
    let visibility:         String?
    
    let startTime:          Int?
    let stopTime:           Int?
    let actualStartTime:    Int?
    let actualStopTime:    Int?
    
    let minParticipants:    Int?
    let maxParticipants:    Int?
    
    let externalLink:   String?

    init(title: String?=nil, body: String?=nil, imageURL: String?=nil, sport: String?=nil, startTime: Int?=nil, maxParticipants: Int?=nil, minParticipants: Int?=nil, level: Int?=nil, actualSTime: Int? = nil, stopTime: Int? = nil, actualStopTime: Int? = nil, visibility: String?=nil, externalLink: String?=nil){
        self.title = title
        self.body = body
        self.imageURL = imageURL
        
        self.level = level
        self.visibility = visibility
        
        self.startTime = startTime
        self.stopTime = stopTime
        self.actualStartTime = actualSTime
        self.actualStopTime = actualStopTime
        
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        
        self.externalLink = externalLink
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(visibility, forKey: .visibility)
        try container.encode(level, forKey: .level)
        try container.encode(startTime, forKey: .startTime)
        if let ast = actualStartTime {
            try container.encode(ast, forKey: .actualStartTime)
        }
        if let st = stopTime {
            try container.encode(st, forKey: .stopTime)
        }
        if let actualStopTime = actualStopTime {
            try container.encode(actualStopTime, forKey: .actualStopTime)
        }
        try container.encode(minParticipants, forKey: .minParticipants)
        try container.encode(maxParticipants, forKey: .maxParticipants)
        try container.encode(externalLink, forKey: .externalLink)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case imageURL = "image_url"
        
        case level
        case visibility
        
        case startTime = "start_time"
        case stopTime = "stop_time"
        
        case actualStartTime = "actual_start_time"
        case actualStopTime = "actual_stop_time"
        
        case minParticipants = "min_participants"
        case maxParticipants = "max_participants"
        
        case externalLink = "external_link"
    }
}
