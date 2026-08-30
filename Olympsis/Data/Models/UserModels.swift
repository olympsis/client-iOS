//
//  UserModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/24/23.
//

import Foundation

struct User: Codable, Hashable {
    var userID: String?
    var username: String?
    let firstName: String?
    let lastName: String?
    let gender: Gender?
    let birthdate: Date?
    var imageURL: String?
    var bio: String?
    var sports: [String]?
    var visibility: String?
    var clubs: [String]?
    var organizations: [String]?
    var acceptedEULA: Bool?
    var hasOnboarded: Bool?
    var blockedUsers: [String]?
    var reportedPosts: [String]?
    var reportedEvents: [String]?
    var hometown: GeoJSON?
    var notificationDevices: [NotificationDevice]?
    var notificationPreference: NotificationPreference?

    // Compare all fields so SwiftUI detects changes when profile data is updated
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userID == rhs.userID
            && lhs.username == rhs.username
            && lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.imageURL == rhs.imageURL
            && lhs.bio == rhs.bio
            && lhs.sports == rhs.sports
            && lhs.visibility == rhs.visibility
            && lhs.hometown == rhs.hometown
    }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case birthdate
        case imageURL = "image_url"
        case bio
        case sports
        case visibility
        case clubs
        case organizations
        case acceptedEULA = "accepted_eula"
        case hasOnboarded = "has_onboarded"
        case blockedUsers = "blocked_users"
        case reportedPosts = "report_posts"
        case reportedEvents = "reported_events"
        case hometown
        case notificationDevices = "notification_devices"
        case notificationPreference = "notification_preference"
    }
    
    init(
        userID: String?=nil,
        username: String?=nil,
        firstName: String?=nil,
        lastName: String?=nil,
        gender: Gender?=nil,
        birthdate: Date?=nil,
        imageURL: String?=nil,
        bio: String?=nil,
        sports: [String]?=nil,
        visibility: String?=nil,
        clubs: [String]?=nil,
        organizations: [String]?=nil,
        acceptedEULA: Bool?=nil,
        hasOnboarded: Bool?=nil,
        blockedUsers: [String]?=nil,
        reportedPosts: [String]?=nil,
        reportedEvents: [String]?=nil,
        hometown: GeoJSON?=nil,
        notificationDevices: [NotificationDevice]? = nil,
        notificationPreference: NotificationPreference? = nil
    ){
        self.userID = userID
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.gender = gender
        self.birthdate = birthdate
        self.imageURL = imageURL
        self.sports = sports
        self.visibility = visibility
        self.clubs = clubs
        self.organizations = organizations
        self.acceptedEULA = acceptedEULA
        self.hasOnboarded = hasOnboarded
        self.blockedUsers = blockedUsers
        self.reportedPosts = reportedPosts
        self.reportedEvents = reportedEvents
        self.hometown = hometown
        self.notificationDevices = notificationDevices
        self.notificationPreference = notificationPreference
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)

        if let genderString = try container.decodeIfPresent(String.self, forKey: .gender) {
           gender = Gender(rawValue: genderString)
        } else {
            gender = nil
        }

        birthdate = try container.decodeIfPresent(Date.self, forKey: .birthdate)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        sports = try container.decodeIfPresent([String].self, forKey: .sports)
        visibility = try container.decodeIfPresent(String.self, forKey: .visibility)
        clubs = try container.decodeIfPresent([String].self, forKey: .clubs)
        organizations = try container.decodeIfPresent([String].self, forKey: .organizations)
        acceptedEULA = try container.decodeIfPresent(Bool.self, forKey: .acceptedEULA)
        hasOnboarded = try container.decodeIfPresent(Bool.self, forKey: .hasOnboarded)
        blockedUsers = try container.decodeIfPresent([String].self, forKey: .blockedUsers)
        reportedPosts = try container.decodeIfPresent([String].self, forKey: .reportedPosts)
        reportedEvents = try container.decodeIfPresent([String].self, forKey: .reportedEvents)
        hometown = try container.decodeIfPresent(GeoJSON.self, forKey: .hometown)
        notificationDevices = try container.decodeIfPresent([NotificationDevice].self, forKey: .notificationDevices)
        notificationPreference = try container.decodeIfPresent(NotificationPreference.self, forKey: .notificationPreference)
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        
        if let genderString = gender?.rawValue {
            try container.encodeIfPresent(genderString, forKey: .gender)
        }
        
        try container.encodeIfPresent(birthdate, forKey: .birthdate)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(sports, forKey: .sports)
        try container.encodeIfPresent(visibility, forKey: .visibility)
        try container.encodeIfPresent(clubs, forKey: .clubs)
        try container.encodeIfPresent(organizations, forKey: .organizations)
        try container.encodeIfPresent(acceptedEULA, forKey: .acceptedEULA)
        try container.encodeIfPresent(hasOnboarded, forKey: .hasOnboarded)
        try container.encodeIfPresent(blockedUsers, forKey: .blockedUsers)
        try container.encodeIfPresent(reportedPosts, forKey: .reportedPosts)
        try container.encodeIfPresent(reportedEvents, forKey: .reportedEvents)
        try container.encodeIfPresent(hometown, forKey: .hometown)
        try container.encodeIfPresent(notificationDevices, forKey: .notificationDevices)
        try container.encodeIfPresent(notificationPreference, forKey: .notificationPreference)
    }
}

extension User {
    /// Project the full `User` down to the `UserSnippet` shape used
    /// by embedded references (post authors, comment authors, RSVP
    /// rows, etc.). Centralizes the field mapping so call sites stop
    /// hand-rolling `UserSnippet(userID:, username:, imageURL:)` and
    /// drift can't sneak in if `UserSnippet` ever grows new fields.
    func toSnippet() -> UserSnippet {
        UserSnippet(
            userID: userID,
            username: username,
            firstName: firstName,
            lastName: lastName,
            imageURL: imageURL
        )
    }
}

struct UserDao: Codable {
    var userID: String?
    var username: String?
    var bio: String?
    var gender: Gender?
    var birthdate: Date?
    var imageURL: String?
    var sports: [String]?
    var visibility: String?
    var clubs: [String]?
    var organizations: [String]?
    var acceptedEULA: Bool?
    var hasOnboarded: Bool?
    var blockedUsers: [String]?
    var reportedPosts: [String]?
    var reportedEvents: [String]?
    var hometown: GeoJSON?
    var notificationDevices: [NotificationDevice]?
    var notificationPreference: NotificationPreference?

    init(
        userID: String?=nil, 
        username: String?=nil,
        bio: String?=nil,
        gender: Gender?=nil,
        birthdate: Date?=nil,
        imageURL: String?=nil,
        sports: [String]?=nil,
        visibility: String?=nil,
        clubs: [String]?=nil,
        organizations: [String]?=nil,
        acceptedEULA: Bool?=nil,
        hasOnboarded: Bool?=nil,
        blockedUsers: [String]?=nil,
        reportedPosts: [String]?=nil,
        reportedEvents: [String]?=nil,
        hometown: GeoJSON?=nil,
        notificationDevices: [NotificationDevice]? = nil,
        notificationPreference: NotificationPreference? = nil
    ){
        self.userID = userID
        self.username = username
        self.bio = bio
        self.gender = gender
        self.birthdate = birthdate
        self.imageURL = imageURL
        self.sports = sports
        self.visibility = visibility
        self.clubs = clubs
        self.organizations = organizations
        self.acceptedEULA = acceptedEULA
        self.hasOnboarded = hasOnboarded
        self.blockedUsers = blockedUsers
        self.reportedPosts = reportedPosts
        self.reportedEvents = reportedEvents
        self.hometown = hometown
        self.notificationDevices = notificationDevices
        self.notificationPreference = notificationPreference
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case username
        case bio
        case gender
        case birthdate
        case imageURL = "image_url"
        case visibility
        case clubs
        case organizations
        case sports
        case acceptedEULA = "accepted_eula"
        case hasOnboarded = "has_onboarded"
        case blockedUsers = "blocked_users"
        case reportedPosts = "report_posts"
        case reportedEvents = "reported_events"
        case hometown
        case notificationDevices = "notification_devices"
        case notificationPreference = "notification_preference"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        
        if let genderString = try container.decodeIfPresent(String.self, forKey: .gender) {
           gender = Gender(rawValue: genderString)
        } else {
            gender = nil
        }
        
        birthdate = try container.decodeIfPresent(Date.self, forKey: .birthdate)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        sports = try container.decodeIfPresent([String].self, forKey: .sports)
        visibility = try container.decodeIfPresent(String.self, forKey: .visibility)
        clubs = try container.decodeIfPresent([String].self, forKey: .clubs)
        organizations = try container.decodeIfPresent([String].self, forKey: .organizations)
        acceptedEULA = try container.decodeIfPresent(Bool.self, forKey: .acceptedEULA)
        hasOnboarded = try container.decodeIfPresent(Bool.self, forKey: .hasOnboarded)
        blockedUsers = try container.decodeIfPresent([String].self, forKey: .blockedUsers)
        reportedPosts = try container.decodeIfPresent([String].self, forKey: .reportedPosts)
        reportedEvents = try container.decodeIfPresent([String].self, forKey: .reportedEvents)
        hometown = try container.decodeIfPresent(GeoJSON.self, forKey: .hometown)
        notificationDevices = try container.decodeIfPresent([NotificationDevice].self, forKey: .notificationDevices)
        notificationPreference = try container.decodeIfPresent(NotificationPreference.self, forKey: .notificationPreference)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(bio, forKey: .bio)
        
        if let genderString = gender?.rawValue {
            try container.encodeIfPresent(genderString, forKey: .gender)
        }
        
        try container.encodeIfPresent(birthdate?.ISO8601Format(), forKey: .birthdate)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(sports, forKey: .sports)
        try container.encodeIfPresent(visibility, forKey: .visibility)
        try container.encodeIfPresent(clubs, forKey: .clubs)
        try container.encodeIfPresent(organizations, forKey: .organizations)
        try container.encodeIfPresent(acceptedEULA, forKey: .acceptedEULA)
        try container.encodeIfPresent(hasOnboarded, forKey: .hasOnboarded)
        try container.encodeIfPresent(blockedUsers, forKey: .blockedUsers)
        try container.encodeIfPresent(reportedPosts, forKey: .reportedPosts)
        try container.encodeIfPresent(reportedEvents, forKey: .reportedEvents)
        try container.encodeIfPresent(hometown, forKey: .hometown)
        try container.encodeIfPresent(notificationDevices, forKey: .notificationDevices)
        try container.encodeIfPresent(notificationPreference, forKey: .notificationPreference)
    }
}

struct UserData: Codable, Hashable {
    let userID: String
    let firstName: String
    let lastName: String
    let username: String
    let gender: Gender?
    let birthday: Date?
    let imageURL: String?
    let bio: String?
    let sports: [String]
    let visibility: String
    let clubs: [String]
    let organizations: [String]
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.userID == rhs.userID
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case gender
        case birthday
        case imageURL = "image_url"
        case bio
        case sports
        case visibility
        case clubs
        case organizations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userID = try container.decode(String.self, forKey: .userID)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        username = try container.decode(String.self, forKey: .username)
        
        if let genderString = try container.decodeIfPresent(String.self, forKey: .gender) {
           gender = Gender(rawValue: genderString)
        } else {
            gender = nil
        }
        
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        sports = try container.decode([String].self, forKey: .sports)
        visibility = try container.decode(String.self, forKey: .visibility)
        clubs = try container.decode([String].self, forKey: .clubs)
        organizations = try container.decode([String].self, forKey: .organizations)
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(userID, forKey: .userID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(username, forKey: .username)
        
        if let genderString = gender?.rawValue {
            try container.encodeIfPresent(genderString, forKey: .gender)
        }
        
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encode(sports, forKey: .sports)
        try container.encode(visibility, forKey: .visibility)
        try container.encode(clubs, forKey: .clubs)
        try container.encode(organizations, forKey: .organizations)
    }
}

struct UsernameAvailabilityResponse: Codable {
    var isAvailable: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isAvailable = "is_available"
    }
}

struct UsersDataResponse: Codable {
    let totalUsers: Int
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalUsers = "total_users"
        case users
    }
}

/// The aggregate payload `GET /v1/users/check-in` returns on launch.
///
/// `invitations` carries the user's pending invites in the invite-service shape
/// (`InviteResponse`) — the same elements `GET /v1/invites/user/{id}` returns.
/// The JSON key kept its old name for wire compatibility, but it is no longer
/// the legacy `Invitation` type.
struct CheckIn: Decodable {
    let user: User?
    let clubs: [Club]?
    let organizations: [Organization]?
    let invitations: [InviteResponse]?

    /// Decoded field-by-field so one bad element can't sink the whole response.
    ///
    /// `InviteResponse` parses its timestamps with `parseDate(from:)`, which
    /// throws when it meets a format it doesn't know. Since check-in is what
    /// authenticates the session, letting that error propagate would cost the
    /// user their whole check-in over a single malformed invite. Invites are
    /// decoded with `try?` so an unparseable batch degrades to "no invites"
    /// instead.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.user = try container.decodeIfPresent(User.self, forKey: .user)
        self.clubs = try container.decodeIfPresent([Club].self, forKey: .clubs)
        self.organizations = try container.decodeIfPresent([Organization].self, forKey: .organizations)
        self.invitations = try? container.decodeIfPresent([InviteResponse].self, forKey: .invitations)
    }

    enum CodingKeys: String, CodingKey {
        case user
        case clubs
        case organizations
        case invitations
    }
}

struct LocationResponse: Decodable {
    let venues: [Venue]?
    let events: [Event]?
}

struct UserSnippet: Codable, Hashable {
    var userID: String?
    var username: String?
    var firstName: String?
    var lastName: String?
    var imageURL: String?
    
    init(userID: String? = nil, username: String? = nil, firstName: String? = nil, lastName: String? = nil, imageURL: String? = nil) {
        self.userID = userID
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case imageURL = "image_url"
    }
}

struct NotificationPreference: Codable, Hashable {
    var types: [String: Bool]       // push, email, phone
    var categories: [String: Bool]  // groups, events
    let updatedAt: Date
    
    init(types: [String: Bool] = [:], categories: [String: Bool] = [:], updatedAt: Date = Date()) {
        self.types = types
        self.categories = categories
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular properties
        types = try container.decodeIfPresent([String: Bool].self, forKey: .types) ?? [:]
        categories = try container.decodeIfPresent([String: Bool].self, forKey: .categories) ?? [:]
        
        // Custom date decoding
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            if let date = dateFormatter.date(from: updatedAtString) {
                updatedAt = date
            } else {
                // If date parsing fails, use current date as fallback
                updatedAt = Date()
            }
        } else {
            // If updatedAt is missing, use current date as default
            updatedAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Encode regular properties
            try container.encode(types, forKey: .types)
            try container.encode(categories, forKey: .categories)
            
            // Custom date encoding to ISO 8601 string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Convert Date object to ISO string
            let updatedAtString = dateFormatter.string(from: updatedAt)
            try container.encode(updatedAtString, forKey: .updatedAt)
        }
    
    enum CodingKeys: String, CodingKey {
        case types
        case categories
        case updatedAt = "updated_at"
    }
}

/// Hardware / OS metadata for a push-notification device.
///
/// Mirrors the server's `DeviceInfo` (models/general.go). These fields MUST be
/// sent nested under `device_info` — the server's `NotificationDevice` has no
/// top-level `platform`/`model` keys, so the old flat encoding was silently
/// dropped on decode and `device_info` was stored as empty strings.
struct DeviceInfo: Codable, Hashable {
    var platform: String?
    var osVersion: String?
    var deviceModel: String?

    enum CodingKeys: String, CodingKey {
        case platform
        case osVersion = "os_version"
        case deviceModel = "device_model"
    }
}

struct NotificationDevice: Codable, Hashable {
    var deviceID: String?
    var token: String?
    var deviceInfo: DeviceInfo?
    var active: Bool?
    let createdAt: Date
    var updatedAt: Date?

    init(deviceID: String?, token: String?, deviceInfo: DeviceInfo?, active: Bool?, createdAt: Date, updatedAt: Date?) {
        self.deviceID = deviceID
        self.token = token
        self.deviceInfo = deviceInfo
        self.active = active
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode regular properties normally
        deviceID = try container.decodeIfPresent(String.self, forKey: .deviceID)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        deviceInfo = try container.decodeIfPresent(DeviceInfo.self, forKey: .deviceInfo)
        active = try container.decodeIfPresent(Bool.self, forKey: .active)

        // Custom date decoding
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }

        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString)
        } else {
            updatedAt = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode regular properties
        try container.encodeIfPresent(deviceID, forKey: .deviceID)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(deviceInfo, forKey: .deviceInfo)
        try container.encodeIfPresent(active, forKey: .active)

        // Convert Date objects to ISO strings
        try container.encode(createdAt.ISO8601Format(), forKey: .createdAt)
        try container.encodeIfPresent(updatedAt?.ISO8601Format(), forKey: .updatedAt)
    }

    static func == (lhs: NotificationDevice, rhs: NotificationDevice) -> Bool {
        return
            lhs.token == rhs.token &&
            lhs.deviceID == rhs.deviceID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(token)
        hasher.combine(deviceID)
    }

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case token
        case deviceInfo = "device_info"
        case active
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
