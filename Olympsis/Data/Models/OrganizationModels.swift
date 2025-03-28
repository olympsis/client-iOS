//
//  OrganizationModels.swift
//  Olympsis
//
//  Created by Joel on 11/21/23.
//

import Foundation

/// A group that can be the parent of many clubs and post announcements that will be show in the clubs.
class Organization: Decodable, Identifiable, ObservableObject {

    let id: String
    var name: String
    var description: String?
    var sports: [String]
    let city: String
    let state: String
    let country: String
    var logo: String?
    var banner: String?
    let members: [Member]
    let blackList: [String]
    var pinnedPosts: [String]
    let isVerified: Bool
    let createdAt: Date
    
    init(id: String,
         name: String,
         description: String?,
         sports: [String],
         city: String,
         state: String,
         country: String,
         logo: String?,
         banner: String?,
         members: [Member],
         blackList: [String],
         pinnedPosts: [String],
         isVerified: Bool,
         createdAt: Date) {
        
        self.id = id
        self.name = name
        self.description = description
        self.sports = sports
        self.city = city
        self.state = state
        self.country = country
        self.logo = logo
        self.banner = banner
        self.members = members
        self.blackList = blackList
        self.pinnedPosts = pinnedPosts
        self.isVerified = isVerified
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Create date formatter for ISO8601 format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Decode regular properties
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        sports = try container.decode([String].self, forKey: .sports)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        country = try container.decode(String.self, forKey: .country)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        banner = try container.decodeIfPresent(String.self, forKey: .banner)
        members = try container.decodeIfPresent([Member].self, forKey: .members) ?? []
        blackList = try container.decodeIfPresent([String].self, forKey: .blackList) ?? []
        pinnedPosts = try container.decodeIfPresent([String].self, forKey: .pinnedPosts) ?? []
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        
        // Handle date decoding with multiple formats
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            if let date = dateFormatter.date(from: createdAtString) {
                createdAt = date
            } else {
                // Fallback to current date if string parsing fails
                createdAt = Date()
            }
        } else if let createdAtInt = try container.decodeIfPresent(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt))
        } else {
            // Use standard Date decoding as last resort
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
    }
    
    static func == (lhs: Organization, rhs: Organization) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sports
        case city
        case state
        case country
        case logo
        case banner
        case members
        case blackList = "black_list"
        case pinnedPosts = "pinned_posts"
        case data
        case isVerified = "is_verified"
        case createdAt = "created_at"
    }
}

struct OrganizationData: Decodable {
    let children: [Club]?
    
    enum CodingKeys: String, CodingKey {
        case children
    }
}

struct OrganizationsResponse: Decodable {
    let totalOrganizations: Int
    let organizations: [Organization]
    
    enum CodingKeys: String, CodingKey {
        case totalOrganizations = "total_organizations"
        case organizations
    }
}

class OrganizationApplication: Decodable, Identifiable {
    let id: String
    var status: String
    let club: Club?
    let createdAt: Int
    
    init(id: String, status: String, club: Club? = nil, createdAt: Int = 0) {
        self.id = id
        self.status = status
        self.club = club
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        club = try container.decodeIfPresent(Club.self, forKey: .club)
        
        // Handle createdAt with format flexibility
        if let createdAtInt = try container.decodeIfPresent(Int.self, forKey: .createdAt) {
            createdAt = createdAtInt
        } else if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            // Try to convert string to Int, assuming it's a numeric string
            if let intValue = Int(createdAtString) {
                createdAt = intValue
            } else {
                // If it's a date string, convert to timestamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                if let date = dateFormatter.date(from: createdAtString) {
                    createdAt = Int(date.timeIntervalSince1970)
                } else {
                    // Default to current time if parsing fails
                    createdAt = Int(Date().timeIntervalSince1970)
                }
            }
        } else {
            // Default to current time if not found
            createdAt = Int(Date().timeIntervalSince1970)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case club
        case createdAt = "created_at"
    }
}

struct OrganizationApplicationDao: Codable {
    let organizationID: String?
    let clubID: String?
    var status: String?
    let createdAt: Date?
    
    init(organizationID: String?=nil, clubID: String?=nil, status: String? = "pending", createdAt: Date?=nil) {
        self.organizationID = organizationID
        self.clubID = clubID
        self.status = status
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case organizationID = "organization_id"
        case clubID = "club_id"
        case status
        case createdAt = "created_at"
    }
}

struct OrganizationApplicationData: Decodable {
    let club: Club?
}

class OrganizationDao: Codable {

    let id: String?
    var name: String?
    var description: String?
    var sports: [String]?
    var city: String?
    var state: String?
    var country: String?
    var logo: String?
    var banner: String?
    var members: [MemberDao]?
    var blackList: [String]?
    var pinnedPosts: [String]?
    
    init(id: String?=nil,
         name: String?=nil,
         description: String?=nil,
         sports: [String]?=nil,
         city: String?=nil,
         state: String?=nil,
         country: String?=nil,
         logo: String?=nil,
         banner: String?=nil,
         members: [MemberDao]?=nil,
         blackList: [String]?=nil,
         pinnedPosts: [String]?=nil) {
        
        self.id = id
        self.name = name
        self.description = description
        self.sports = sports
        self.city = city
        self.state = state
        self.country = country
        self.logo = logo
        self.banner = banner
        self.members = members
        self.blackList = blackList
        self.pinnedPosts = pinnedPosts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        sports = try container.decodeIfPresent([String].self, forKey: .sports)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        banner = try container.decodeIfPresent(String.self, forKey: .banner)
        members = try container.decodeIfPresent([MemberDao].self, forKey: .members)
        blackList = try container.decodeIfPresent([String].self, forKey: .blackList)
        pinnedPosts = try container.decodeIfPresent([String].self, forKey: .pinnedPosts)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sports
        case city
        case state
        case country
        case logo
        case banner
        case members
        case blackList = "black_list"
        case pinnedPosts = "pinned_posts"
    }
}
