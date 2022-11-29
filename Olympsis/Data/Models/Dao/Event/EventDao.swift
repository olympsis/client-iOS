//
//  NewEventDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/26/22.
//

import Foundation

class EventDao: Dao {
    let title:              String
    let body:               String
    let clubId:             String?
    let fieldId:            String
    let imageURL:           String
    let sport:              String
    let startTime:          Int
    let maxParticipants:    Int
    let level:              Int
    let status:             String
    
    // optionals
    let actualStartTime:    Int?
    let stopTime:           Int?

    init(_title: String, _body: String, _clubId: String? = nil, _fieldId: String, _imageURL: String, _sport: String, _startTime: Int, _maxParticipants: Int, _level: Int, _actualSTime: Int? = nil, _stopTime: Int? = nil, _status: String){
        self.title = _title
        self.body = _body
        self.clubId = _clubId
        self.fieldId = _fieldId
        self.imageURL = _imageURL
        self.sport = _sport
        self.startTime = _startTime
        self.maxParticipants = _maxParticipants
        self.level = _level
        self.actualStartTime = _actualSTime
        self.stopTime = _stopTime
        self.status = _status
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
        if let cid = clubId {
            try container.encode(cid, forKey: .clubId)
        }
        try container.encode(fieldId, forKey: .fieldId)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(sport, forKey: .sport)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(maxParticipants, forKey: .maxParticipants)
        try container.encode(level, forKey: .level)
        if let ast = actualStartTime {
            try container.encode(ast, forKey: .actualStartTime)
        }
        if let st = stopTime {
            try container.encode(st, forKey: .stopTime)
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
        case startTime
        case maxParticipants
        case level
        case actualStartTime
        case stopTime
        case status
    }
}
