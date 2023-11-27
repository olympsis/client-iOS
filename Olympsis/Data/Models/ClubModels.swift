//
//  ClubModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/30/23.
//

import Foundation

class Club: Codable, Identifiable {

    let id: String?
    let parentId: String?
    let type: String?
    let name: String?
    let description: String?
    let sport: String?
    let city: String?
    let state: String?
    let country: String?
    let imageURL: String?
    let imageGallery: [String]?
    let visibility: String?
    let members: [Member]?
    let rules: [String]?
    let data: ClubData?
    let pinnedPostId: String?
    let createdAt: Int64?
    
    init(id: String?,
         parentId: String?,
         type: String?,
         name: String?,
         description: String?,
         sport: String?,
         city: String?,
         state: String?,
         country: String?,
         imageURL: String?,
         imageGallery: [String]?,
         visibility: String?,
         members: [Member]?,
         rules: [String]?,
         data: ClubData?,
         pinnedPostId: String?,
         createdAt: Int64?) {
        
        self.id = id
        self.parentId = parentId
        self.type = type
        self.name = name
        self.description = description
        self.sport = sport
        self.city = city
        self.state = state
        self.country = country
        self.imageURL = imageURL
        self.imageGallery = imageGallery
        self.visibility = visibility
        self.members = members
        self.rules = rules
        self.data = data
        self.pinnedPostId = pinnedPostId
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
        case parentId
        case type
        case name
        case description
        case sport
        case city
        case state
        case country
        case imageURL = "image_url"
        case imageGallery = "image_gallery"
        case visibility
        case members
        case rules
        case data
        case pinnedPostId
        case createdAt = "created_at"
    }
}

class Member: Codable, Identifiable {
    
    let id: String?
    let uuid: String
    let role: String
    let data: UserData?
    let joinedAt: Int64?
    
    init(id: String?,
         uuid: String,
         role: String,
         data: UserData?,
         joinedAt: Int64?) {
        
        self.id = id
        self.uuid = uuid
        self.role = role
        self.data = data
        self.joinedAt = joinedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case role
        case data
        case joinedAt = "joined_at"
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
    let uuid: String
    let clubID: String
    let status: String
    let data: UserData?
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
