//
//  ClubModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/30/23.
//

import Foundation

struct Club: Codable, Identifiable {
    let id: String?
    let name: String?
    let description: String?
    let sport: String?
    let city: String?
    let state: String?
    let country: String?
    let imageURL: String?
    let visibility: String?
    let members: [Member]?
    let rules: [String]?
    let createdAt: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sport
        case city
        case state
        case country
        case imageURL = "image_url"
        case visibility
        case members
        case rules
        case createdAt = "created_at"
    }
}

struct Member: Codable, Identifiable {
    let id: String?
    let uuid: String
    let role: String
    let data: UserData?
    let joinedAt: Int64?
    
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
