//
//  GenericModels.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import Foundation
import MapKit

struct Invitation: Codable {
    var id: String?
    var type: String
    let sender: String
    let recipient: String
    let subjectID: String
    var status: String
    let data: InvitationData?
    let createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case sender
        case recipient
        case subjectID = "subject_id"
        case status
        case data
        case createdAt = "created_at"
    }
}

struct InvitationData: Codable {
    let club: Club?
    let event: Event?
    let organization: Organization?
}

struct InvitationsResponse: Codable {
    let totalInvitations: Int
    let invitations: [Invitation]
    
    enum CodingKeys: String, CodingKey {
        case totalInvitations = "total_invitations"
        case invitations
    }
}

struct Comment: Codable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String?
    let text: String
    var user: UserSnippet?
    let createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case user
        case createdAt = "created_at"
    }
}

struct CommentDao: Codable {
    let id: String?
    let text: String
    var uuid: String?
    let createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case uuid
        case createdAt = "created_at"
    }
}

struct Like: Codable, Identifiable {
    static func == (lhs: Like, rhs: Like) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String?
    let uuid: String
    let user: UserSnippet?
    let createdAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case user
        case createdAt = "created_at"
    }
}

struct LikeDao: Codable {
    
    let uuid: String
    
    enum CodingKeys: String, CodingKey {
        case uuid
    }
}

struct CreateResponse: Codable {
    let id: String?
}


struct CustomField: Identifiable {
    let id = UUID()
    let item: MKMapItem
}

struct SelectedCustomField {
    var field: FieldDescriptor?
    var administrativeArea: String
    var subAdministrativeArea: String
    var country: String
    
    init(field: FieldDescriptor? = nil, administrativeArea: String="", subAdministrativeArea: String="", country: String="") {
        self.field = field
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.country = country
    }
}

class Member: Codable, Identifiable {
    
    let id: String?
    let role: String
    let user: UserSnippet?
    let joinedAt: Int64?
    
    init(id: String?,
         role: String,
         user: UserSnippet?,
         joinedAt: Int64?) {
        
        self.id = id
        self.role = role
        self.user = user
        self.joinedAt = joinedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case user
        case joinedAt = "joined_at"
    }
}

class MemberDao: Codable, Identifiable {
    
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
