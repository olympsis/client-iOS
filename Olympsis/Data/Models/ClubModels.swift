//
//  ClubModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/30/23.
//

import Foundation

class Club: Codable, Identifiable, ObservableObject {

    let id: String?
    let parent: OrganizationDao?
    let name: String?
    var logo: String?
    var banner: String?
    let sports: [String]?
    let description: String?
    let city: String?
    let state: String?
    let country: String?
    let visibility: String?
    var members: [Member]
    var blackList: [String]?
    let rules: [String]?
    var tags: [String]?
    var pinnedPosts: [String]?
    let isVerified: Bool?
    let createdAt: Int?
    
    init(id: String?,
         parent: OrganizationDao?,
         name: String?,
         logo: String?,
         banner: String?,
         sports: [String]?,
         description: String?,
         city: String?,
         state: String?,
         country: String?,
         visibility: String?,
         members: [Member] = [Member](),
         blackList: [String]?=nil,
         rules: [String]?=nil,
         tags: [String]?=nil,
         pinnedPosts: [String]?,
         isVerified: Bool=false,
         createdAt: Int?) {
        
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
        self.visibility = visibility
        self.members = members
        self.blackList = blackList
        self.rules = rules
        self.tags = tags
        self.pinnedPosts = pinnedPosts
        self.isVerified = isVerified
        self.createdAt = createdAt
    }
    
    static func == (lhs: Club, rhs: Club) -> Bool {
        guard let lhsID = lhs.id,
              let rhsID = rhs.id else {
            return false
        }
        return lhsID == rhsID
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
        case visibility
        case members
        case blackList
        case rules
        case tags
        case pinnedPosts = "pinned_posts"
    }
}

struct ClubInvite: Codable, Identifiable {
    let id: String
    let uuid: String
    let clubID: String
    let status: String
    let createdAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case clubID = "club_id"
        case status
        case createdAt = "created_at"
    }
}

struct ClubResponse: Codable {
    let token: String?
    let club: Club
    
    enum CodingKeys: String, CodingKey {
        case token
        case club
    }
}

struct ClubsResponse: Codable {
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

struct CreateClubResponse: Codable {
    let token: String
    let club: Club
}

struct ApplicationUpdateRequest: Codable {
    let status: String
}

struct ClubApplication: Codable, Identifiable {
    let id: String
    let applicant: UserData?
    let status: String
    let createdAt: Int64
    
    init(id: String, applicant: UserData?, status: String, createdAt: Int64) {
        self.id = id
        self.applicant = applicant
        self.status = status
        self.createdAt = createdAt
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

struct ClubInvitation: Codable, Identifiable {
    let id: String
    let uuid: String
    let clubID: String
    let status: String
    let data: Club?
    let createdAt: Int64
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case clubID = "club_id"
        case status
        case data
        case createdAt = "created_at"
    }
}

/// Holds extra club data such as the parent organization data. Eventually i will add club metrics in this struct
struct ClubData: Codable {
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
