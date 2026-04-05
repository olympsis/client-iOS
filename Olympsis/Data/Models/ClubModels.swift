//
//  ClubModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/30/23.
//

import Foundation

@Observable
class Club: Decodable, Identifiable, Hashable {

    let id: String
    let parent: OrganizationDao?
    var name: String
    var logo: String?
    var banner: String?
    var sports: [String]
    var description: String?
    let city: String
    let state: String
    let country: String
    let location: GeoJSON
    let visibility: String
    var members: [Member]
    var blackList: [String]?
    let rules: [String]
    var tags: [String]
    var pinnedPosts: [String]
    let isVerified: Bool
    let createdAt: Date
    
    init(id: String,
         parent: OrganizationDao?,
         name: String,
         logo: String?,
         banner: String?,
         sports: [String],
         description: String?,
         city: String,
         state: String,
         country: String,
         location: GeoJSON,
         visibility: String,
         members: [Member] = [Member](),
         blackList: [String] = [],
         rules: [String] = [],
         tags: [String] = [],
         pinnedPosts: [String] = [],
         isVerified: Bool=false,
         createdAt: Date) {
        
        self.id = id
        self.parent = parent
        self.name = name
        self.logo = logo
        self.banner = banner
        self.description = description
        self.sports = sports
        self.city = city
        self.state = state
        self.country = country
        self.location = location
        self.visibility = visibility
        self.members = members
        self.blackList = blackList
        self.rules = rules
        self.tags = tags
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
        self.id = try container.decode(String.self, forKey: .id)
        self.parent = try container.decodeIfPresent(OrganizationDao.self, forKey: .parent)
        self.name = try container.decode(String.self, forKey: .name)
        self.logo = try container.decodeIfPresent(String.self, forKey: .logo)
        self.banner = try container.decodeIfPresent(String.self, forKey: .banner)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.sports = try container.decode([String].self, forKey: .sports)
        self.city = try container.decode(String.self, forKey: .city)
        self.state = try container.decode(String.self, forKey: .state)
        self.country = try container.decode(String.self, forKey: .country)
        self.location = try container.decode(GeoJSON.self, forKey: .location)
        self.visibility = try container.decode(String.self, forKey: .visibility)
        self.members = try container.decode([Member].self, forKey: .members)
        self.blackList = try container.decodeIfPresent([String].self, forKey: .blackList)
        self.rules = try container.decodeIfPresent([String].self, forKey: .rules) ?? []
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.pinnedPosts = try container.decodeIfPresent([String].self, forKey: .pinnedPosts) ?? []
        self.isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        
        // Handle date decoding with multiple formats
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = try parseDate(from: createdAtString)
        } else {
            // Use standard Date decoding as last resort
            self.createdAt = Date()
        }
    }
    
    static func == (lhs: Club, rhs: Club) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parent
        case name
        case logo
        case banner
        case description
        case sports
        case city
        case state
        case country
        case location
        case visibility
        case members
        case blackList
        case rules
        case tags
        case pinnedPosts = "pinned_posts"
        case isVerified = "is_verified"
        case createdAt = "created_at"
    }
}

class ClubDao: Codable, Identifiable {

    var id: String?
    var parentId: String?
    var name: String?
    var logo: String?
    var banner: String?
    var description: String?
    var sports: [String]?
    var city: String?
    var state: String?
    var country: String?
    var location: GeoJSON?
    var visibility: String?
    var members: [Member]?
    var blackList: [String]?
    var rules: [String]?
    var tags: [String]?
    var pinnedPosts: [String]?
    
    init(id: String?=nil,
         parentId: String?=nil,
         name: String?=nil,
         logo: String?=nil,
         banner: String?=nil,
         description: String?=nil,
         sports: [String]?=nil,
         city: String?=nil,
         state: String?=nil,
         country: String?=nil,
         location: GeoJSON?=nil,
         visibility: String?=nil,
         members: [Member]?=nil,
         blackList: [String]?=nil,
         rules: [String]?=nil,
         tags: [String]?=nil,
         pinnedPosts: [String]?=nil) {
        
        self.id = id
        self.parentId = parentId
        self.name = name
        self.logo = logo
        self.banner = banner
        self.description = description
        self.sports = sports
        self.city = city
        self.state = state
        self.country = country
        self.location = location
        self.visibility = visibility
        self.blackList = blackList
        self.members = members
        self.rules = rules
        self.tags = tags
        self.pinnedPosts = pinnedPosts
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case name
        case logo
        case banner
        case description
        case sports
        case city
        case state
        case country
        case location
        case visibility
        case members
        case blackList
        case rules
        case tags
        case pinnedPosts = "pinned_posts"
    }
}

class ClubInvite: Codable, Identifiable {
    let id: String
    let userID: String
    let clubID: String
    let status: String
    let createdAt: Date
    
    init(id: String,
         userID: String,
         clubID: String,
         status: String,
         createdAt: Date) {
        self.id = id
        self.userID = userID
        self.clubID = clubID
        self.status = status
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
        userID = try container.decode(String.self, forKey: .userID)
        clubID = try container.decode(String.self, forKey: .clubID)
        status = try container.decode(String.self, forKey: .status)
        
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userID, forKey: .userID)
        try container.encode(clubID, forKey: .clubID)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case clubID = "club_id"
        case status
        case createdAt = "created_at"
    }
}

struct ClubResponse: Decodable {
    let token: String?
    let club: Club
    
    enum CodingKeys: String, CodingKey {
        case token
        case club
    }
}

struct ClubsResponse: Decodable {
    let totalClubs: Int
    let clubs: [Club]
    
    enum CodingKeys: String, CodingKey {
        case totalClubs = "total_clubs"
        case clubs
    }
}

struct ClubInvites: Codable {
    let totalInvites: Int
    let invites: [ClubInvite]
    
    enum CodingKeys: String, CodingKey {
        case totalInvites = "total_invites"
        case invites
    }
}

struct ChangeRoleRequest: Codable {
    let role: String
}

struct CreateClubResponse: Decodable {
    let token: String
    let club: Club
}

struct ApplicationUpdateRequest: Codable {
    let status: String
}

class ClubApplication: Codable, Identifiable {
    let id: String
    let applicant: User?
    let status: String
    let createdAt: Date
    
    init(id: String, applicant: User?, status: String, createdAt: Date) {
        self.id = id
        self.applicant = applicant
        self.status = status
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
        applicant = try container.decodeIfPresent(User.self, forKey: .applicant)
        status = try container.decode(String.self, forKey: .status)
        
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(applicant, forKey: .applicant)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case applicant
        case status
        case createdAt = "created_at"
    }
}

struct ClubApplicationsResponse: Codable {
    let totalApplications: Int
    let applications: [ClubApplication]
    
    enum CodingKeys: String, CodingKey {
        case totalApplications = "total_applications"
        case applications = "club_applications"
    }
}

class ClubInvitation: Decodable, Identifiable {
    let id: String
    let userID: String
    let clubID: String
    let status: String
    let data: Club?
    let createdAt: Date
    
    init(id: String, userID: String, clubID: String, status: String, data: Club?, createdAt: Date) {
        self.id = id
        self.userID = userID
        self.clubID = clubID
        self.status = status
        self.data = data
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
        userID = try container.decode(String.self, forKey: .userID)
        clubID = try container.decode(String.self, forKey: .clubID)
        status = try container.decode(String.self, forKey: .status)
        data = try container.decodeIfPresent(Club.self, forKey: .data)
        
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case clubID = "club_id"
        case status
        case data
        case createdAt = "created_at"
    }
}

/// Holds extra club data such as the parent organization data. Eventually i will add club metrics in this struct
struct ClubData: Decodable {
    let parent: Organization?
    
    enum CodingKeys: String, CodingKey {
        case parent
    }
}

struct ClubSnippet: Codable {
    let id: String
    let name: String
    let description: String
    let sports: [String]
    let city: String
    let state: String
    let country: String
    let visibility: String
}

struct OrgSnippet: Codable {
    let id: String
    let name: String
    let description: String
    let sports: [String]
    let city: String
    let state: String
    let country: String
}
