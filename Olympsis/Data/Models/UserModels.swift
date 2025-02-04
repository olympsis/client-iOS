//
//  UserModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/24/23.
//

import Foundation

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
    let deviceTokens: [String]?

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
        deviceTokens: [String]? = nil
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
        self.deviceTokens = deviceTokens
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
        case deviceTokens = "device_tokens"
    }
}

struct UsernameAvailabilityResponse: Codable {
    var isAvailable: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isAvailable = "is_available"
    }
}

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
    var deviceTokens: [String]?
    
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
        case deviceTokens = "device_tokens"
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
