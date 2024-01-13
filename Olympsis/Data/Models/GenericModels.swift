//
//  GenericModels.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import Foundation

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

struct CreateResponse: Codable {
    let id: String?
}
