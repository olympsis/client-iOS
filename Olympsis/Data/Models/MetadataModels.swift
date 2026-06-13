//
//  MetadataModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import Foundation
import NotificationCenter

struct NotificationMetadata {
    
    var type: NotificationType
    
    var userID: String?
    var username: String?
    var userImageURL: String?
    
    var postID: String?
    var postImageURL: String?
    
    var groupT: String?
    var groupID: String?
    var groupName: String?
    var groupImageURL: String?
    
    var eventID: String?
    var eventName: String?
    var eventImageURL: String?
    var eventStartTime: Date?
    var eventStopTime: Date?

    var content: String?

    init(
        type: NotificationType,
        
        userID: String?=nil,
        username: String?=nil,
        userImageURL: String?=nil,
        
        postID: String?=nil,
        postImageURL: String?=nil,
        
        groupT: String?=nil,
        groupID: String?=nil,
        groupName: String?=nil,
        groupImageURL: String?=nil,
        
        eventID: String?=nil,
        eventName: String?=nil,
        eventImageURL: String?=nil,
        eventStartTime: Date?=nil,
        eventStopTime: Date?=nil,

        content: String?=nil
    ){
        self.type = type
        self.postID = postID
        self.postImageURL = postImageURL
        
        self.userID = userID
        self.username = username
        self.userImageURL = userImageURL
        
        self.groupT = groupT
        self.groupID = groupID
        self.groupName = groupName
        self.groupImageURL = groupImageURL
        
        self.eventID = eventID
        self.eventName = eventName
        self.eventImageURL = eventImageURL
        self.eventStartTime = eventStartTime
        self.eventStopTime = eventStopTime

        self.content = content
    }
    
    init?(from notification: UNNotification) throws {
        let userInfo = notification.request.content.userInfo
        guard let _type = userInfo["type"] as? String,
              let type = NotificationType(rawValue: _type) else {
            return nil
        }
        
        self.type = type
        
        self.userID = userInfo["user_id"] as? String
        self.username = userInfo["username"] as? String
        self.userImageURL = userInfo["user_image_url"] as? String
        
        self.postID = userInfo["post_id"] as? String
        self.postImageURL = userInfo["post_image_url"] as? String
         
        self.groupT = userInfo["group_type"] as? String
        self.groupID = userInfo["group_id"] as? String
        self.groupName = userInfo["group_name"] as? String
        self.groupImageURL = userInfo["group_logo_url"] as? String
        
        self.eventID = userInfo["event_id"] as? String
        self.eventName = userInfo["event_name"] as? String
        self.eventImageURL = userInfo["event_image_url"] as? String

        self.content = userInfo["content"] as? String
        
        if let startDate = userInfo["event_start_date"] as? String {
            self.eventStartTime = try parseDate(from: startDate)
        }
        
        if let stopDate = userInfo["event_stop_date"] as? String {
            self.eventStopTime = try parseDate(from: stopDate)
        }
    }
}
