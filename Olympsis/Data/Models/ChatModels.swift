//
//  ChatModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/12/23.
//

import Foundation

struct Room: Codable, Identifiable {
    let id: String?
    let name: String
    let type: String
    let clubID: String?
    let members: [ChatMember]
    let history: [Message]?
    
    init(id: String?=nil, name: String, type: String, clubID: String?=nil, members: [ChatMember], history: [Message]?) {
        self.id = id
        self.name = name
        self.type = type
        self.clubID = clubID
        self.members = members
        self.history = history
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case clubID = "club_id"
        case members
        case history
    }
}

struct ChatMember: Codable {
    let id: String?
    let uuid: String
    let status: String
}

struct Message: Codable, Identifiable {
    let id: Int?
    let type: String
    let sender: String
    let body: String
    let timestamp: Int64?
    
    init(id: Int?=nil, type: String, sender: String, body: String, timestamp: Int64?=nil) {
        self.id = id
        self.type = type
        self.sender = sender
        self.body = body
        self.timestamp = timestamp
    }
}

struct RoomsResponse: Decodable {
    let totalRooms: Int
    let rooms: [Room]
    
    enum CodingKeys: String, CodingKey {
        case totalRooms = "total_rooms"
        case rooms
    }
}

