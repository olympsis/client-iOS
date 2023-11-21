//
//  OrganizationModels.swift
//  Olympsis
//
//  Created by Joel on 11/21/23.
//

import Foundation

/// A group that can be the parent of many clubs and post announcements that will be show in the clubs.
class Organization: Codable, Identifiable {

    let id: String?
    let name: String?
    let description: String?
    let sport: String?
    let city: String?
    let state: String?
    let country: String?
    let imageURL: String?
    let imageGallery: [String]?
    let members: [Member]?
    let pinnedPostId: String?
    let data: ClubData?
    let createdAt: Int64?
    
    init(id: String?,
         name: String?,
         description: String?,
         sport: String?,
         city: String?,
         state: String?,
         country: String?,
         imageURL: String?,
         imageGallery: [String]?,
         members: [Member]?,
         createdAt: Int64?) {
        
        self.id = id
        self.name = name
        self.description = description
        self.sport = sport
        self.city = city
        self.state = state
        self.country = country
        self.imageURL = imageURL
        self.imageGallery = imageGallery
        self.members = members
        self.pinnedPostId = nil
        self.data = nil
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
        case sport
        case city
        case state
        case country
        case imageURL = "image_url"
        case imageGallery = "image_gallery"
        case members
        case pinnedPostId = "pinned_post_id"
        case data
        case createdAt = "created_at"
    }
}

struct OrganizationData: Codable {
    let children: [Club]?
    
    enum CodingKeys: String, CodingKey {
        case children
    }
}
