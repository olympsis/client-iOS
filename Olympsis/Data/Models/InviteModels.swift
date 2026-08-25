//
//  InviteModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/24/26.
//

import Foundation

/// A single invite as returned by the API.
///
/// `contextID` points at whatever resource `type` describes — an event ID for
/// `.event`, a club ID for `.club`, and so on.
struct InviteResponse: Decodable, Identifiable, Hashable {
    var id: String
    var type: InviteType
    var contextID: String
    var inviteeID: String
    var requestorID: String
    var status: InviteStatus
    var createdAt: Date
    var updatedAt: Date

    init(id: String,
         type: InviteType,
         contextID: String,
         inviteeID: String,
         requestorID: String,
         status: InviteStatus,
         createdAt: Date,
         updatedAt: Date) {
        self.id = id
        self.type = type
        self.contextID = contextID
        self.inviteeID = inviteeID
        self.requestorID = requestorID
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// The server sends timestamps as ISO8601 strings, which the default
    /// `JSONDecoder` date strategy can't read. `parseDate(from:)` handles the
    /// handful of formats the backend emits; a missing timestamp falls back to
    /// `Date()` so a partial payload doesn't drop the whole invite.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(InviteType.self, forKey: .type)
        self.contextID = try container.decode(String.self, forKey: .contextID)
        self.inviteeID = try container.decode(String.self, forKey: .inviteeID)
        self.requestorID = try container.decode(String.self, forKey: .requestorID)
        self.status = try container.decode(InviteStatus.self, forKey: .status)

        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = try parseDate(from: createdAtString)
        } else {
            self.createdAt = Date()
        }

        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            self.updatedAt = try parseDate(from: updatedAtString)
        } else {
            self.updatedAt = self.createdAt
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case contextID = "context_id"
        case inviteeID = "invitee_id"
        case requestorID = "requestor_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Body for creating a single invite.
struct CreateInviteRequest: Codable {
    var type: InviteType
    var contextID: String
    var inviteeID: String
    var requestorID: String

    enum CodingKeys: String, CodingKey {
        case type
        case contextID = "context_id"
        case inviteeID = "invitee_id"
        case requestorID = "requestor_id"
    }
}

/// Body for updating an invite's status.
///
/// `response` is only meaningful when accepting an event invite — it carries
/// the RSVP the invitee picked. It's omitted from the payload when `nil`.
struct UpdateInviteRequest: Codable {
    var status: InviteStatus
    var response: RSVPStatus?

    enum CodingKeys: String, CodingKey {
        case status
        case response
    }
}

/// Paginated list of the current user's invites. `nextCursor` is empty when
/// there are no more pages.
struct UserInvitesResponse: Decodable {
    var invites: [InviteResponse]
    var nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case invites
        case nextCursor = "next_cursor"
    }
}
