//
//  FieldModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation
import CoreLocation

class Venue: Codable, Identifiable, Equatable, Hashable {
    
    let id: String
    let name: String
    let owner: Ownership
    let description: String
    let sports: [String]
    let images: [String]
    let location: GeoJSON
    let city: String
    let state: String
    let country: String
    
    let bookingURL: String?
    let requiresBooking: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case description
        case sports
        case images
        case location
        case city
        case state
        case country
        case bookingURL = "booking_url"
        case requiresBooking = "requires_booking"
    }
    
    init(id: String, name: String, owner: Ownership, description: String, sports: [String], images: [String], location: GeoJSON, city: String, state: String, country: String, bookingURL: String?=nil, requiresBooking: Bool=false) {
        self.id = id
        self.name = name
        self.owner = owner
        self.description = description
        self.sports = sports
        self.images = images
        self.location = location
        self.city = city
        self.state = state
        self.country = country
        
        self.bookingURL = bookingURL
        self.requiresBooking = requiresBooking
    }
    
    convenience init(name: String, location: GeoJSON, city: String, state: String, country: String) {
        self.init(
            id: UUID().uuidString, 
            name: name,
            owner: Ownership(name: "", type: ""),
            description: "external", sports: [String](),
            images: [String](),
            location: location,
            city: city,
            state: state,
            country: country,
            bookingURL: nil,
            requiresBooking: false
        )
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.owner = try container.decode(Ownership.self, forKey: .owner)
        self.description = try container.decode(String.self, forKey: .description)
        self.sports = try container.decode([String].self, forKey: .sports)
        self.images = try container.decode([String].self, forKey: .images)
        self.location = try container.decode(GeoJSON.self, forKey: .location)
        self.city = try container.decode(String.self, forKey: .city)
        self.state = try container.decode(String.self, forKey: .state)
        self.country = try container.decode(String.self, forKey: .country)
        self.bookingURL = try container.decodeIfPresent(String.self, forKey: .bookingURL)
        self.requiresBooking = try container.decodeIfPresent(Bool.self, forKey: .requiresBooking) ?? false
    }
    
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id || (lhs.name == rhs.name && lhs.location == rhs.location)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location)
    }
    
    func isPublic() -> Bool {
        return owner.type == "public" ? true : false
    }
}

struct GeoJSON: Codable, Hashable {
    let type: String
    let coordinates: [Double]
    
    static func == (lhs: GeoJSON, rhs: GeoJSON) -> Bool {
        let threshold = 0.0005
        return (abs(lhs.coordinates[0] - rhs.coordinates[0]) <= threshold &&
        abs(lhs.coordinates[1] - rhs.coordinates[1]) <= threshold)
    }
    
    func hash(into hasher: inout Hasher) {
        // Round coordinates to the nearest threshold bucket
        let threshold = 0.0005
        let bucketLong = (coordinates[0] / threshold).rounded() * threshold
        let bucketLat = (coordinates[1] / threshold).rounded() * threshold
        hasher.combine(type)
        hasher.combine(bucketLong)
        hasher.combine(bucketLat)
    }
}

struct Ownership: Codable, Hashable {
    static func == (lhs: Ownership, rhs: Ownership) -> Bool {
        return lhs.name == rhs.name
    }
    let name: String
    let type: String
}

struct VenuesResponse: Codable {
    let fields: [Venue]
    let totalFields: Int
    
    private enum CodingKeys: String, CodingKey {
        case fields
        case totalFields = "total_fields"
    }
}

extension [Venue] {
    func locale() -> String {
        guard let firstVenue = self.first else {
            return "Location, ERR"
        }

        let allInSameCityState = self.allSatisfy { $0.city == firstVenue.city && $0.state == firstVenue.state }
        if allInSameCityState {
            return "\(firstVenue.city), \(firstVenue.state)"
        }

        let allInSameState = self.allSatisfy { $0.state == firstVenue.state }
        if allInSameState {
            return firstVenue.state
        }

        let allInSameCountry = self.allSatisfy { $0.country == firstVenue.country }
        if allInSameCountry {
            return firstVenue.country
        }

        return "Location, ERR"
    }
}

struct VenueDescriptor: Codable, Hashable {
    let id: String?
    var name: String?
    var city: String?
    var state: String?
    var country: String?
    var location: GeoJSON?
    
    init(id: String?=nil, name: String?, city: String?, state: String?, country: String?, location: GeoJSON?=nil) {
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.country = country
        self.location = location
    }
    
    func isInternal() -> Bool {
        guard self.id != nil else {
            return false
        }
        return true
    }

    
    func geocode() async -> [CLPlacemark]? {
        let geocoder = CLGeocoder()
        guard let coordinates = self.location?.coordinates else {
            return nil
        }
        let coreLoc = CLLocation(latitude: coordinates[1], longitude: coordinates[0])
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(coreLoc) { placemarks, _ in
                continuation.resume(returning: placemarks ?? [])
            }
        }
    }
}
