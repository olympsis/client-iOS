//
//  UserModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/24/23.
//

import Foundation

struct UserData: Codable, Hashable {
    var uuid: String?
    var username: String?
    let firstName: String?
    let lastName: String?
    var imageURL: String?
    var bio: String?
    var sports: [String]?
    var visibility: String?
    var clubs: [String]?
    var organizations: [String]?
    var acceptedEULA: Bool?
    var hasOnboarded: Bool?
    var blockedUsers: [String]?
    var reportedPosts: [String]?
    var reportedEvents: [String]?
    var hometown: [Double]?
    var notificationDevices: [NotificationDevice]?
    var notificationPreference: NotificationPreference?
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        guard let lhsID = lhs.uuid,
              let rhsID = rhs.uuid else {
            return false
        }
        return lhsID == rhsID
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case imageURL = "image_url"
        case bio
        case sports
        case visibility
        case clubs
        case organizations
        case acceptedEULA = "accepted_eula"
        case hasOnboarded = "has_onboarded"
        case blockedUsers = "blocked_users"
        case reportedPosts = "report_posts"
        case reportedEvents = "reported_events"
        case hometown
        case notificationDevices = "notification_devices"
        case notificationPreference = "notification_preference"
    }
}

struct UserDao: Codable {
    let uuid: String?
    let username: String?
    let bio: String?
    let imageURL: String?
    let sports: [String]?
    let visibility: String?
    let clubs: [String]?
    var organizations: [String]?
    var acceptedEULA: Bool?
    var hasOnboarded: Bool?
    var blockedUsers: [String]?
    var reportedPosts: [String]?
    var reportedEvents: [String]?
    var hometown: [Double]?
    var notificationDevices: [NotificationDevice]?
    var notificationPreference: NotificationPreference?

    init(
        uuid: String?=nil, 
        username: String?=nil,
        bio: String?=nil,
        imageURL: String?=nil,
        sports: [String]?=nil,
        visibility: String?=nil,
        clubs: [String]?=nil,
        organizations: [String]?=nil,
        acceptedEULA: Bool?=nil,
        hasOnboarded: Bool?=nil,
        blockedUsers: [String]?=nil,
        reportedPosts: [String]?=nil,
        reportedEvents: [String]?=nil,
        hometown: [Double]?=nil,
        notificationDevices: [NotificationDevice]? = nil,
        notificationPreference: NotificationPreference? = nil
    ){
        self.uuid = uuid
        self.username = username
        self.bio = bio
        self.imageURL = imageURL
        self.sports = sports
        self.visibility = visibility
        self.clubs = clubs
        self.organizations = organizations
        self.acceptedEULA = acceptedEULA
        self.hasOnboarded = hasOnboarded
        self.blockedUsers = blockedUsers
        self.reportedPosts = reportedPosts
        self.reportedEvents = reportedEvents
        self.hometown = hometown
        self.notificationDevices = notificationDevices
        self.notificationPreference = notificationPreference
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case bio
        case imageURL = "image_url"
        case visibility
        case clubs
        case organizations
        case sports
        case acceptedEULA = "accepted_eula"
        case hasOnboarded = "has_onboarded"
        case blockedUsers = "blocked_users"
        case reportedPosts = "report_posts"
        case reportedEvents = "reported_events"
        case hometown
        case notificationDevices = "notification_devices"
        case notificationPreference = "notification_preference"
    }
}

struct UsernameAvailabilityResponse: Codable {
    var isAvailable: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isAvailable = "is_available"
    }
}

struct UsersDataResponse: Codable {
    let totalUsers: Int
    let users: [UserData]
    
    enum CodingKeys: String, CodingKey {
        case totalUsers = "total_users"
        case users
    }
}

struct CheckIn: Decodable {
    let user: UserData?
    let clubs: [Club]?
    let organizations: [Organization]?
    let invitations: [Invitation]?
}

struct LocationResponse: Decodable {
    let venues: [Venue]?
    let events: [Event]?
}

struct UserSnippet: Codable, Hashable {
    var uuid: String?
    var username: String?
    var imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case username
        case imageURL = "image_url"
    }
}

struct NotificationPreference: Codable, Hashable {
    var types: [String: Bool]       // push, email, phone
    var categories: [String: Bool]  // groups, events
    let updatedAt: Date
    
    init(types: [String: Bool] = [:], categories: [String: Bool] = [:], updatedAt: Date = Date()) {
        self.types = types
        self.categories = categories
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular properties
        types = try container.decodeIfPresent([String: Bool].self, forKey: .types) ?? [:]
        categories = try container.decodeIfPresent([String: Bool].self, forKey: .categories) ?? [:]
        
        // Custom date decoding
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            if let date = dateFormatter.date(from: updatedAtString) {
                updatedAt = date
            } else {
                // If date parsing fails, use current date as fallback
                updatedAt = Date()
            }
        } else {
            // If updatedAt is missing, use current date as default
            updatedAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Encode regular properties
            try container.encode(types, forKey: .types)
            try container.encode(categories, forKey: .categories)
            
            // Custom date encoding to ISO 8601 string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Convert Date object to ISO string
            let updatedAtString = dateFormatter.string(from: updatedAt)
            try container.encode(updatedAtString, forKey: .updatedAt)
        }
    
    enum CodingKeys: String, CodingKey {
        case types
        case categories
        case updatedAt = "updated_at"
    }
}

struct NotificationDevice: Codable, Hashable {
    var deviceID: String?
    var token: String?
    var platform: DevicePlatform?  // ios, android, web
    var model: String?
    var active: Bool?
    let createdAt: Date
    var updatedAt: Date?
    
    init(deviceID: String?, token: String?, platform: DevicePlatform?, model: String?, active: Bool?, createdAt: Date, updatedAt: Date?) {
        self.deviceID = deviceID
        self.token = token
        self.platform = platform
        self.model = model
        self.active = active
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular properties normally
        deviceID = try container.decodeIfPresent(String.self, forKey: .deviceID)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        platform = try container.decodeIfPresent(DevicePlatform.self, forKey: .platform)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        active = try container.decodeIfPresent(Bool.self, forKey: .active)
        
        // Custom date decoding
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString)
        } else {
            updatedAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode regular properties
        try container.encodeIfPresent(deviceID, forKey: .deviceID)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(platform, forKey: .platform)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encodeIfPresent(active, forKey: .active)
        
        // Custom date encoding to ISO 8601 string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Convert Date objects to ISO strings
        let createdAtString = dateFormatter.string(from: createdAt)
        try container.encode(createdAtString, forKey: .createdAt)
        
        if let updatedAt = updatedAt {
            let updatedAtString = dateFormatter.string(from: updatedAt)
            try container.encode(updatedAtString, forKey: .updatedAt)
        }
    }
    
    static func == (lhs: NotificationDevice, rhs: NotificationDevice) -> Bool {
        return
            lhs.token == rhs.token &&
            lhs.model == rhs.model &&
            lhs.platform == rhs.platform
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(token)
        hasher.combine(model)
        hasher.combine(platform)
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case token
        case platform
        case model
        case active
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
