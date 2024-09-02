//
//  MetadataModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import Foundation

struct NotificationMetadata: Codable {
    
    var type: String
    
    var userId: String?
    var username: String?
    var userImageURL: String?
    
    var postId: String?
    var postImageURL: String?
    
    var groupId: String?
    var groupName: String?
    var groupImageURL: String?
    
    var eventId: String?
    var eventName: String?
    var eventImageURL: String?
    
    var url: String?
    
    var timestamp: Int?
    
    init(
        type: String="status",
        userId: String?=nil,
        username: String?=nil,
        userImageURL: String?=nil,
        postId: String?=nil,
        postImageURL: String?=nil,
        groupId: String?=nil,
        groupName: String?=nil,
        groupImageURL: String?=nil,
        eventId: String?=nil,
        eventName: String?=nil,
        eventImageURL: String?=nil,
        url: String?=nil,
        timestamp: Int?=nil
    ){
        self.type = type
        self.postId = postId
        self.postImageURL = postImageURL
        
        self.userId = userId
        self.username = username
        self.userImageURL = userImageURL
        
        self.groupId = groupId
        self.groupName = groupName
        self.groupImageURL = groupImageURL
        
        self.eventId = eventId
        self.eventName = eventName
        self.eventImageURL = eventImageURL
        
        self.url = url
        
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case userId = "user_id"
        case username = "username"
        case userImageURL = "user_image_url"
        
        case postId = "post_id"
        case postImageURL = "post_image_url"
        
        case groupId = "group_id"
        case groupName = "group_name"
        case groupImageURL = "group_image_url"
        
        case eventId = "event_id"
        case eventName = "event_name"
        case eventImageURL = "event_image_url"
        
        case timestamp
    }
}
