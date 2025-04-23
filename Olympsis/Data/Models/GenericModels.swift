//
//  GenericModels.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import Foundation
import MapKit

enum Gender: String, CaseIterable {
    case Male = "male"
    case Female = "female"
    case NonBinary = "non_binary"
    case PreferNotToSay = "prefer_not_to_say"
}

struct Invitation: Decodable {
    var id: String?
    var type: String
    let sender: String
    let recipient: String
    let subjectID: String
    var status: String
    let data: InvitationData?
    let createdAt: Date?
    
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

struct InvitationDTO: Codable {
    var id: String?
    var type: String
    let sender: String
    let recipient: String
    let subjectID: String
    var status: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case sender
        case recipient
        case subjectID = "subject_id"
        case status
        case createdAt = "created_at"
    }
}

struct InvitationData: Decodable {
    let club: Club?
    let event: Event?
    let organization: Organization?
}

struct InvitationsResponse: Decodable {
    let totalInvitations: Int
    let invitations: [Invitation]
    
    enum CodingKeys: String, CodingKey {
        case totalInvitations = "total_invitations"
        case invitations
    }
}

struct Comment: Codable {
    
    let id: String
    let text: String
    var user: UserSnippet?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, text: String, user: UserSnippet? = nil, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.user = user
        self.createdAt = createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = try parseDate(from: createdAtString)
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
    
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
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case uuid
        case createdAt = "created_at"
    }
}

struct Reaction: Codable, Identifiable {
    static func == (lhs: Reaction, rhs: Reaction) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let uuid: String
    let user: UserSnippet?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, uuid: String = UUID().uuidString, user: UserSnippet? = nil, createdAt: Date = Date()) {
        self.id = id
        self.uuid = uuid
        self.user = user
        self.createdAt = createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = try parseDate(from: createdAtString)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case user
        case createdAt = "created_at"
    }
}

struct ReactionDao: Codable {
    
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
    var field: VenueDescriptor?
    var administrativeArea: String
    var subAdministrativeArea: String
    var country: String
    
    init(field: VenueDescriptor? = nil, administrativeArea: String="", subAdministrativeArea: String="", country: String="") {
        self.field = field
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.country = country
    }
}

class Member: Codable, Identifiable, ObservableObject {
    
    let id: String?
    let role: String?
    let user: UserSnippet?
    let joinedAt: Date?
    
    @Published var isBlocked: Bool = false
    @Published var roleEnum: MEMBER_ROLES = .Member
    
    init(id: String?,
         role: String,
         user: UserSnippet?,
         joinedAt: Date?) {
        
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular properties
        id = try container.decodeIfPresent(String.self, forKey: .id)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        user = try container.decodeIfPresent(UserSnippet.self, forKey: .user)
        
        // Create date formatter for ISO8601 format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Handle date decoding with multiple formats
        if let joinedAtString = try container.decodeIfPresent(String.self, forKey: .joinedAt) {
            joinedAt = dateFormatter.date(from: joinedAtString)
        } else if let joinedAtInt = try container.decodeIfPresent(Int.self, forKey: .joinedAt) {
            joinedAt = Date(timeIntervalSince1970: TimeInterval(joinedAtInt))
        } else {
            joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
        }
        
        // Initialize published properties
        isBlocked = false
        roleEnum = .Member
        
        // Call the helper methods to set up the object
        if let r = role, let e = MEMBER_ROLES(rawValue: r) {
            roleEnum = e
        }
    }
    
    func checkBlockStatus(_ user: User) {
        guard let blockedUsers = user.blockedUsers,
              let data = self.user,
              let memberUID = data.uuid else {
            self.isBlocked = false
            return
        }
        self.isBlocked = blockedUsers.contains(where: { $0 == memberUID })
    }
    
    func checkRole() {
        guard let r = role,
              let e = MEMBER_ROLES(rawValue: r) else {
            self.roleEnum = .Member
            return
        }
        self.roleEnum = e
    }
}

class MemberDao: Codable, Identifiable {
    
    let id: String?
    let uuid: String
    let role: String
    let data: User?
    let joinedAt: Date?
    
    init(id: String?,
         uuid: String,
         role: String,
         data: User?,
         joinedAt: Date?) {
        
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular properties
        id = try container.decodeIfPresent(String.self, forKey: .id)
        uuid = try container.decode(String.self, forKey: .uuid)
        role = try container.decode(String.self, forKey: .role)
        data = try container.decodeIfPresent(User.self, forKey: .data)
        
        // Create date formatter for ISO8601 format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Handle date decoding with multiple formats
        if let joinedAtString = try container.decodeIfPresent(String.self, forKey: .joinedAt) {
            joinedAt = dateFormatter.date(from: joinedAtString)
        } else if let joinedAtInt = try container.decodeIfPresent(Int.self, forKey: .joinedAt) {
            joinedAt = Date(timeIntervalSince1970: TimeInterval(joinedAtInt))
        } else {
            joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
        }
    }
}

class Tag: Codable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class Sport: Codable, Equatable {
    
    var name: String
    var images: [String]
    
    init(name: String, images: [String]) {
        self.name = name
        self.images = images
    }
    
    static func == (lhs: Sport, rhs: Sport) -> Bool {
        return lhs.name == rhs.name
    }
}

class ApplicationConfiguration: Codable {
    var sports: [Sport]
    var tags: [Tag]
}

struct DayGroup: Identifiable {
    let id = UUID()
    let date: Date
    var events: [Event]
    
    var dayInString: String {
        return events[0].timeToString()
    }
}

struct Country: Codable, Identifiable, Hashable {
    
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.id == rhs.id
    }
    
}

struct AdministrativeArea: Codable, Identifiable, Hashable {
    
    let id: String
    let name: String
    let countryID: String
    
    init(id: String, name: String, countryID: String) {
        self.id = id
        self.name = name
        self.countryID = countryID
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryID = "country_id"
    }
    
    static func == (lhs: AdministrativeArea, rhs: AdministrativeArea) -> Bool {
        lhs.id == rhs.id
    }
}

struct SubAdministrativeArea: Codable, Identifiable, Hashable {
    
    let id: String
    let name: String
    let adminAreaID: String
    let location: GeoJSON
    
    init(id: String, name: String, adminAreaID: String, location: GeoJSON) {
        self.id = id
        self.name = name
        self.adminAreaID = adminAreaID
        self.location = location
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case adminAreaID = "admin_area_id"
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        adminAreaID = try container.decode(String.self, forKey: .adminAreaID)
        location = try container.decode(GeoJSON.self, forKey: .location)
    }
    
    static func == (lhs: SubAdministrativeArea, rhs: SubAdministrativeArea) -> Bool {
        lhs.id == rhs.id
    }
}
