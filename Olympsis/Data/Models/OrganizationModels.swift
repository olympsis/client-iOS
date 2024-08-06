//
//  OrganizationModels.swift
//  Olympsis
//
//  Created by Joel on 11/21/23.
//

import Foundation

/// A group that can be the parent of many clubs and post announcements that will be show in the clubs.
class Organization: Codable, Identifiable, ObservableObject {

    let id: String?
    var name: String?
    var description: String?
    var sports: [String]?
    let city: String?
    let state: String?
    let country: String?
    var logo: String?
    var banner: String?
    let members: [Member]?
    let blackList: [String]?
    var pinnedPosts: [String]?
    let data: ClubData?
    let isVerified: Bool?
    let createdAt: Int?
    
    init(id: String?,
         name: String?,
         description: String?,
         sports: [String]?,
         city: String?,
         state: String?,
         country: String?,
         logo: String?,
         banner: String?,
         members: [Member]?,
         blackList: [String]?,
         pinnedPosts: [String]?,
         isVerified: Bool?,
         createdAt: Int?) {
        
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
        self.data = nil
        self.isVerified = isVerified
        self.createdAt = createdAt
    }
    
    static func == (lhs: Organization, rhs: Organization) -> Bool {
        guard let lhsID = lhs.id,
              let rhsID = rhs.id else {
            return false
        }
        return lhsID == rhsID
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

struct OrganizationsResponse: Codable {
    let totalOrganizations: Int
    let organizations: [Organization]
    
    enum CodingKeys: String, CodingKey {
        case totalOrganizations = "total_organizations"
        case organizations
    }
}

struct OrganizationApplication: Decodable, Identifiable {
    let id: String
    var status: String
    let club: Club?
    let createdAt: Int
    
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
    let createdAt: Int?
    
    init(organizationID: String?=nil, clubID: String?=nil, status: String? = "pending", createdAt: Int?=nil) {
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
