//
//  FieldModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation
import CoreLocation

class Venue: Codable, Identifiable, Equatable {
    
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
    }
    
    init(id: String, name: String, owner: Ownership, description: String, sports: [String], images: [String], location: GeoJSON, city: String, state: String, country: String) {
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
            country: country
        )
    }
    
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isPublic() -> Bool {
        return owner.type == "public" ? true : false
    }
}

struct GeoJSON: Codable, Hashable {
    static func == (lhs: GeoJSON, rhs: GeoJSON) -> Bool {
        return (lhs.coordinates[0] == rhs.coordinates[0]) && (lhs.coordinates[1] == rhs.coordinates[1])
    }
    let type: String
    let coordinates: [Double]
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
    var name: String
    var city: String
    var state: String
    var country: String
    var location: GeoJSON?
    
    init(id: String?=nil, name: String, city: String, state: String, country: String, location: GeoJSON?=nil) {
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
