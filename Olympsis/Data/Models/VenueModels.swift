//
//  VenueModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//
//  Aligned with Source/models/venue.go.
//
//  Legacy field names (city / state / country / images / fullAddress / bookingURL /
//  requiresBooking / owner / isPublic) are kept as computed shims so existing
//  callers keep compiling while the API migration proceeds.
//

import Foundation
import CoreLocation

// MARK: - Geo / Ownership

/// Typed GeoJSON geometry. Mirrors the four shapes the backend stores:
///
///     Point        → [Double]            (lng, lat)
///     LineString   → [[Double]]
///     Polygon      → [[[Double]]]        (rings of points; first ring = outer)
///     MultiPolygon → [[[[Double]]]]      (array of polygons)
///
/// `.empty` is used for known-type-but-no-coordinates (legacy seed data does
/// `GeoJSON(type: "Point", coordinates: [])`); `.unknown` covers any other
/// type the API may add later, so decoding never throws on new geometry types.
enum Geometry: Hashable {
    case point([Double])
    case lineString([[Double]])
    case polygon([[[Double]]])
    case multiPolygon([[[[Double]]]])
    case empty
    case unknown
}

struct GeoJSON: Codable, Hashable {
    let type: String
    let geometry: Geometry

    /// Legacy accessor — returns the Point coordinate pair when this is a
    /// Point geometry, otherwise an empty array. Callers that need polygon
    /// or multi-polygon data should read `geometry` directly.
    var coordinates: [Double] {
        if case .point(let c) = geometry { return c }
        return []
    }

    // MARK: - Initializers

    /// Point convenience — preserves the original call signature.
    init(type: String, coordinates: [Double]) {
        self.type = type
        self.geometry = coordinates.isEmpty ? .empty : .point(coordinates)
    }

    init(type: String, lineString: [[Double]]) {
        self.type = type
        self.geometry = lineString.isEmpty ? .empty : .lineString(lineString)
    }

    init(type: String, polygon: [[[Double]]]) {
        self.type = type
        self.geometry = polygon.isEmpty ? .empty : .polygon(polygon)
    }

    init(type: String, multiPolygon: [[[[Double]]]]) {
        self.type = type
        self.geometry = multiPolygon.isEmpty ? .empty : .multiPolygon(multiPolygon)
    }

    init(type: String, geometry: Geometry) {
        self.type = type
        self.geometry = geometry
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        self.type = type

        // Dispatch coordinate decoding by geometry type. Comparison is
        // case-insensitive because the backend has historically used both
        // "Point" and "point" in seed data.
        let normalized = type.lowercased()

        // Coordinates may be missing / null on legacy records; treat as empty.
        guard c.contains(.coordinates),
              try c.decodeNil(forKey: .coordinates) == false else {
            self.geometry = .empty
            return
        }

        switch normalized {
        case "point":
            let raw = try c.decode([Double].self, forKey: .coordinates)
            self.geometry = raw.isEmpty ? .empty : .point(raw)
        case "linestring":
            let raw = try c.decode([[Double]].self, forKey: .coordinates)
            self.geometry = raw.isEmpty ? .empty : .lineString(raw)
        case "polygon":
            let raw = try c.decode([[[Double]]].self, forKey: .coordinates)
            self.geometry = raw.isEmpty ? .empty : .polygon(raw)
        case "multipolygon":
            let raw = try c.decode([[[[Double]]]].self, forKey: .coordinates)
            self.geometry = raw.isEmpty ? .empty : .multiPolygon(raw)
        default:
            // Unknown / future geometry type — try Point first since that's
            // the most common; fall back to `.unknown` so decoding never
            // fails the whole parent document for an unrecognized shape.
            if let raw = try? c.decode([Double].self, forKey: .coordinates) {
                self.geometry = raw.isEmpty ? .empty : .point(raw)
            } else {
                self.geometry = .unknown
            }
        }
    }

    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type, forKey: .type)
        switch geometry {
        case .point(let coords):
            try c.encode(coords, forKey: .coordinates)
        case .lineString(let coords):
            try c.encode(coords, forKey: .coordinates)
        case .polygon(let coords):
            try c.encode(coords, forKey: .coordinates)
        case .multiPolygon(let coords):
            try c.encode(coords, forKey: .coordinates)
        case .empty, .unknown:
            // Encode an empty Point-shaped array — matches the legacy
            // "no coords yet" sentinel the iOS app already produces.
            try c.encode([Double](), forKey: .coordinates)
        }
    }

    // MARK: - Equatable / Hashable

    static func == (lhs: GeoJSON, rhs: GeoJSON) -> Bool {
        switch (lhs.geometry, rhs.geometry) {
        case let (.point(a), .point(b)):
            // Threshold equality so two pins within ~50m collapse into one
            // (used for de-duping venues at the same spot).
            guard a.count >= 2, b.count >= 2 else { return a == b }
            let threshold = 0.0005
            return abs(a[0] - b[0]) <= threshold && abs(a[1] - b[1]) <= threshold
        default:
            // Non-point geometries: exact structural equality.
            return lhs.geometry == rhs.geometry
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        switch geometry {
        case .point(let coords) where coords.count >= 2:
            // Round to the threshold bucket so == values hash the same.
            let threshold = 0.0005
            let bucketLong = (coords[0] / threshold).rounded() * threshold
            let bucketLat = (coords[1] / threshold).rounded() * threshold
            hasher.combine(bucketLong)
            hasher.combine(bucketLat)
        case .point(let coords):
            hasher.combine(coords)
        case .lineString(let coords):
            hasher.combine(coords)
        case .polygon(let coords):
            hasher.combine(coords)
        case .multiPolygon(let coords):
            hasher.combine(coords)
        case .empty:
            hasher.combine(0)
        case .unknown:
            hasher.combine(-1)
        }
    }
}

/// Legacy embedded-ownership type. The new API stores only `owner_id` on Venue;
/// `Ownership` is retained for previews / seed data and for other models that
/// still reference it.
struct Ownership: Codable, Hashable {
    let name: String
    let type: String

    static func == (lhs: Ownership, rhs: Ownership) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: - Surface / Reservation status
//
// Stored on the wire as plain strings; the enums below cover the known cases
// from `Source/models/variables.go` but unknown values from the server fall
// back to the raw string on the parent model.

enum Surface: String, Codable, CaseIterable {
    case hard
    case clay
    case grass
    case carpet
    case artificialClay = "artificial_clay"
    case artificialGrass = "artificial_grass"

    case naturalGrass = "natural_grass"
    case artificialTurf = "artificial_turf"
    case hybridTurf = "hybrid_turf"

    case hardwood
    case synthetic
    case sportCourt = "sport_court"
    case concrete
    case asphalt

    case sand
    case ice
    case water
    case track
    case gymFloor = "gym_floor"
    case wood
    case turf
}

enum ReservationStatus: String, Codable, CaseIterable {
    case pending
    case confirmed
    case completed
    case cancelled
    case refunded
    case expired
}

// MARK: - Availability building blocks

/// A single open window inside a weekly schedule.
/// `day` is a lowercase day name ("monday", "tuesday", ...);
/// `open` / `close` are "HH:MM" in 24-hour format.
struct TimeSlot: Codable, Hashable {
    let day: String
    let open: String
    let close: String

    init(day: String, open: String, close: String) {
        self.day = day
        self.open = open
        self.close = close
    }
}

/// A full-day closure on a specific date.
struct BlackoutTimeSlot: Codable, Hashable {
    let date: Date
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case date
        case reason
    }

    init(date: Date, reason: String? = nil) {
        self.date = date
        self.reason = reason
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try c.decode(String.self, forKey: .date)
        self.date = try parseDate(from: dateString)
        self.reason = try c.decodeIfPresent(String.self, forKey: .reason)
    }
}

/// An override of regular hours on a specific date (e.g. holiday hours).
struct SpecialTimeSlot: Codable, Hashable {
    let date: Date
    let open: String
    let close: String
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case date
        case open
        case close
        case reason
    }

    init(date: Date, open: String, close: String, reason: String? = nil) {
        self.date = date
        self.open = open
        self.close = close
        self.reason = reason
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try c.decode(String.self, forKey: .date)
        self.date = try parseDate(from: dateString)
        self.open = try c.decode(String.self, forKey: .open)
        self.close = try c.decode(String.self, forKey: .close)
        self.reason = try c.decodeIfPresent(String.self, forKey: .reason)
    }
}

/// A weekly schedule that applies only between `startDay` and `endDay`
/// (inclusive). Date strings can be `"MM-DD"` (recurring yearly) or
/// `"YYYY-MM-DD"` (one-off window).
/// See the Go model comments for resolution rules.
struct SeasonalHours: Codable, Hashable {
    let name: String
    let startDay: String
    let endDay: String
    let hours: [TimeSlot]
    let closed: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case startDay = "start_day"
        case endDay = "end_day"
        case hours
        case closed
    }

    init(name: String, startDay: String, endDay: String, hours: [TimeSlot] = [], closed: Bool = false) {
        self.name = name
        self.startDay = startDay
        self.endDay = endDay
        self.hours = hours
        self.closed = closed
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decode(String.self, forKey: .name)
        self.startDay = try c.decode(String.self, forKey: .startDay)
        self.endDay = try c.decode(String.self, forKey: .endDay)
        self.hours = try c.decodeIfPresent([TimeSlot].self, forKey: .hours) ?? []
        self.closed = try c.decodeIfPresent(Bool.self, forKey: .closed) ?? false
    }
}

/// Embedded on both Venue and VenueUnit. See Go model for full semantics.
struct Availability: Codable, Hashable {
    let regularHours: [TimeSlot]
    let seasonalHours: [SeasonalHours]
    let blackoutDates: [BlackoutTimeSlot]
    let specialDates: [SpecialTimeSlot]

    enum CodingKeys: String, CodingKey {
        case regularHours = "regular_hours"
        case seasonalHours = "seasonal_hours"
        case blackoutDates = "blackout_dates"
        case specialDates = "special_dates"
    }

    init(
        regularHours: [TimeSlot] = [],
        seasonalHours: [SeasonalHours] = [],
        blackoutDates: [BlackoutTimeSlot] = [],
        specialDates: [SpecialTimeSlot] = []
    ) {
        self.regularHours = regularHours
        self.seasonalHours = seasonalHours
        self.blackoutDates = blackoutDates
        self.specialDates = specialDates
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.regularHours = try c.decodeIfPresent([TimeSlot].self, forKey: .regularHours) ?? []
        self.seasonalHours = try c.decodeIfPresent([SeasonalHours].self, forKey: .seasonalHours) ?? []
        self.blackoutDates = try c.decodeIfPresent([BlackoutTimeSlot].self, forKey: .blackoutDates) ?? []
        self.specialDates = try c.decodeIfPresent([SpecialTimeSlot].self, forKey: .specialDates) ?? []
    }
}

// MARK: - Venue capability descriptors

struct VenueFeatures: Codable, Hashable {
    let indoor: Bool
    let accessible: Bool
    let illuminated: Bool

    init(indoor: Bool = false, accessible: Bool = false, illuminated: Bool = false) {
        self.indoor = indoor
        self.accessible = accessible
        self.illuminated = illuminated
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.indoor = try c.decodeIfPresent(Bool.self, forKey: .indoor) ?? false
        self.accessible = try c.decodeIfPresent(Bool.self, forKey: .accessible) ?? false
        self.illuminated = try c.decodeIfPresent(Bool.self, forKey: .illuminated) ?? false
    }
}

struct VenueAccess: Codable, Hashable {
    let requiresPermit: Bool
    let requiresBooking: Bool
    let requiresMembership: Bool

    enum CodingKeys: String, CodingKey {
        case requiresPermit = "requires_permit"
        case requiresBooking = "requires_booking"
        case requiresMembership = "requires_membership"
    }

    init(requiresPermit: Bool = false, requiresBooking: Bool = false, requiresMembership: Bool = false) {
        self.requiresPermit = requiresPermit
        self.requiresBooking = requiresBooking
        self.requiresMembership = requiresMembership
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.requiresPermit = try c.decodeIfPresent(Bool.self, forKey: .requiresPermit) ?? false
        self.requiresBooking = try c.decodeIfPresent(Bool.self, forKey: .requiresBooking) ?? false
        self.requiresMembership = try c.decodeIfPresent(Bool.self, forKey: .requiresMembership) ?? false
    }
}

struct VenueCapabilities: Codable, Hashable {
    let supportsQueue: Bool
    let supportsWaitTimes: Bool

    enum CodingKeys: String, CodingKey {
        case supportsQueue = "supports_queue"
        case supportsWaitTimes = "supports_wait_times"
    }

    init(supportsQueue: Bool = false, supportsWaitTimes: Bool = false) {
        self.supportsQueue = supportsQueue
        self.supportsWaitTimes = supportsWaitTimes
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.supportsQueue = try c.decodeIfPresent(Bool.self, forKey: .supportsQueue) ?? false
        self.supportsWaitTimes = try c.decodeIfPresent(Bool.self, forKey: .supportsWaitTimes) ?? false
    }
}

// MARK: - Venue units (bookable courts / fields) and rates

/// Price for a venue unit on a specific day + time-range. `rateMinor` is in
/// the smallest currency unit (cents for USD). `timeRange` is "HH:MM-HH:MM".
struct VenueUnitRate: Codable, Hashable {
    let day: String
    let timeRange: String
    let currency: String
    let rateMinor: Int64

    enum CodingKeys: String, CodingKey {
        case day
        case timeRange = "time_range"
        case currency
        case rateMinor = "rate_minor"
    }
}

/// A bookable sub-resource of a venue: a specific court, field, lane, etc.
/// `surface` is stored as a raw string (see `Surface` enum for known values).
struct VenueUnit: Codable, Hashable, Identifiable {
    let id: String
    let venueID: String
    let name: String
    let unitType: String
    let location: GeoJSON
    let surface: String
    let surfaceColor: String
    let sports: [String]
    let rates: [VenueUnitRate]
    let availability: Availability

    enum CodingKeys: String, CodingKey {
        case id
        case venueID = "venue_id"
        case name
        case unitType = "unit_type"
        case location
        case surface
        case surfaceColor = "surface_color"
        case sports
        case rates
        case availability
    }

    init(
        id: String,
        venueID: String,
        name: String,
        unitType: String,
        location: GeoJSON,
        surface: String = "",
        surfaceColor: String = "",
        sports: [String] = [],
        rates: [VenueUnitRate] = [],
        availability: Availability = Availability()
    ) {
        self.id = id
        self.venueID = venueID
        self.name = name
        self.unitType = unitType
        self.location = location
        self.surface = surface
        self.surfaceColor = surfaceColor
        self.sports = sports
        self.rates = rates
        self.availability = availability
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.venueID = try c.decode(String.self, forKey: .venueID)
        self.name = try c.decode(String.self, forKey: .name)
        self.unitType = try c.decodeIfPresent(String.self, forKey: .unitType) ?? ""
        self.location = try c.decode(GeoJSON.self, forKey: .location)
        self.surface = try c.decodeIfPresent(String.self, forKey: .surface) ?? ""
        self.surfaceColor = try c.decodeIfPresent(String.self, forKey: .surfaceColor) ?? ""
        self.sports = try c.decodeIfPresent([String].self, forKey: .sports) ?? []
        self.rates = try c.decodeIfPresent([VenueUnitRate].self, forKey: .rates) ?? []
        self.availability = try c.decodeIfPresent(Availability.self, forKey: .availability) ?? Availability()
    }

    /// Convenience: parsed surface value when it matches a known case.
    var parsedSurface: Surface? { Surface(rawValue: surface) }
}

// MARK: - Transit lines

/// A public-transit line (subway / bus / train) serving the venue.
/// Stored in its own collection in Mongo and referenced by ID from `Venue`,
/// but the iOS API hydrates the full document for rendering.
struct TransitLine: Codable, Hashable, Identifiable {
    let id: String
    let type: String
    let name: String
    let system: String
    let color: String
    let iconURL: String
    let locality: String
    let administrativeArea: String
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case system
        case color
        case iconURL = "icon_url"
        case locality
        case administrativeArea = "administrative_area"
        case countryCode = "country_code"
    }
}

// MARK: - Venue

class Venue: Codable, Identifiable, Equatable, Hashable {

    // New (Go-aligned) fields.
    let id: String
    let ownerID: String
    let name: String
    let venueDescription: String
    let availability: Availability

    let sports: [String]
    let media: [String]
    let url: String

    let address: String
    let location: GeoJSON
    let locality: String?
    let subLocality: String?
    let administrativeArea: String
    let countryCode: String
    let timezone: String

    let units: [VenueUnit]
    let transitLines: [TransitLine]

    let features: VenueFeatures
    let access: VenueAccess
    let capabilities: VenueCapabilities

    let amenities: [String]

    let createdAt: Date?
    let updatedAt: Date?

    // Legacy embedded ownership. Real API responses will not include it
    // (the new schema only stores `owner_id`); preview/seed data may still
    // populate it via the legacy initializer.
    let owner: Ownership

    // MARK: - Legacy field shims
    //
    // These let existing call sites (UI, NewEventManager, etc.) keep
    // compiling while the migration proceeds. Each shim derives from the
    // closest equivalent on the new model.
    var description: String { venueDescription }
    var images: [String] { media }
    var fullAddress: String? { address.isEmpty ? nil : address }
    var bookingURL: String? { url.isEmpty ? nil : url }
    var requiresBooking: Bool { access.requiresBooking }
    var city: String { locality ?? "" }
    var state: String { administrativeArea }
    var country: String { countryCode }

    func isPublic() -> Bool {
        // Legacy semantics. With the new model the API no longer exposes
        // public/private ownership directly; fall back to the old field if
        // present, otherwise treat venues with no booking gate as public.
        if !owner.type.isEmpty {
            return owner.type == "public"
        }
        return !access.requiresBooking && !access.requiresMembership && !access.requiresPermit
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case ownerID = "owner_id"
        case name
        case venueDescription = "description"
        case availability

        case sports
        case media
        case url

        case address
        case location
        case locality
        case subLocality = "sub_locality"
        case administrativeArea = "administrative_area"
        case countryCode = "country_code"
        case timezone

        case units
        case transitLines = "transit_lines"

        case features
        case access
        case capabilities

        case amenities

        case createdAt = "created_at"
        case updatedAt = "updated_at"

        // Legacy keys still accepted on decode for back-compat.
        case owner
        case images
        case city
        case state
        case country
        case fullAddress = "full_address"
        case bookingURL = "booking_url"
        case requiresBooking = "requires_booking"
    }

    // MARK: - Designated initializer (new shape)

    init(
        id: String,
        ownerID: String = "",
        name: String,
        description: String = "",
        availability: Availability = Availability(),
        sports: [String] = [],
        media: [String] = [],
        url: String = "",
        address: String = "",
        location: GeoJSON,
        locality: String? = nil,
        subLocality: String? = nil,
        administrativeArea: String = "",
        countryCode: String = "",
        timezone: String = "",
        units: [VenueUnit] = [],
        transitLines: [TransitLine] = [],
        features: VenueFeatures = VenueFeatures(),
        access: VenueAccess = VenueAccess(),
        capabilities: VenueCapabilities = VenueCapabilities(),
        amenities: [String] = [],
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        owner: Ownership = Ownership(name: "", type: "")
    ) {
        self.id = id
        self.ownerID = ownerID
        self.name = name
        self.venueDescription = description
        self.availability = availability
        self.sports = sports
        self.media = media
        self.url = url
        self.address = address
        self.location = location
        self.locality = locality
        self.subLocality = subLocality
        self.administrativeArea = administrativeArea
        self.countryCode = countryCode
        self.timezone = timezone
        self.units = units
        self.transitLines = transitLines
        self.features = features
        self.access = access
        self.capabilities = capabilities
        self.amenities = amenities
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.owner = owner
    }

    // MARK: - Legacy-shaped initializers
    //
    // Kept so existing seed data / preview data / SessionStore code that
    // builds Venues with the old field names continues to compile until
    // those call sites are migrated.

    convenience init(
        id: String,
        name: String,
        owner: Ownership,
        description: String,
        sports: [String],
        images: [String],
        location: GeoJSON,
        city: String,
        state: String,
        country: String,
        fullAddress: String? = nil,
        bookingURL: String? = nil,
        requiresBooking: Bool = false
    ) {
        self.init(
            id: id,
            ownerID: "",
            name: name,
            description: description,
            sports: sports,
            media: images,
            url: bookingURL ?? "",
            address: fullAddress ?? "",
            location: location,
            locality: city,
            administrativeArea: state,
            countryCode: country,
            access: VenueAccess(requiresBooking: requiresBooking),
            owner: owner
        )
    }

    convenience init(
        name: String,
        location: GeoJSON,
        city: String,
        state: String,
        country: String,
        fullAddress: String? = nil
    ) {
        self.init(
            id: UUID().uuidString,
            name: name,
            owner: Ownership(name: "", type: ""),
            description: "external",
            sports: [],
            images: [],
            location: location,
            city: city,
            state: state,
            country: country,
            fullAddress: fullAddress
        )
    }

    // MARK: - Decode (accepts new and legacy keys)

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try c.decode(String.self, forKey: .id)
        self.ownerID = try c.decodeIfPresent(String.self, forKey: .ownerID) ?? ""
        self.name = try c.decode(String.self, forKey: .name)
        self.venueDescription = try c.decodeIfPresent(String.self, forKey: .venueDescription) ?? ""
        self.availability = try c.decodeIfPresent(Availability.self, forKey: .availability) ?? Availability()

        self.sports = try c.decodeIfPresent([String].self, forKey: .sports) ?? []

        // Prefer new `media`; fall back to legacy `images`.
        if let media = try c.decodeIfPresent([String].self, forKey: .media) {
            self.media = media
        } else {
            self.media = try c.decodeIfPresent([String].self, forKey: .images) ?? []
        }

        // Prefer new `url`; fall back to legacy `booking_url`.
        if let url = try c.decodeIfPresent(String.self, forKey: .url) {
            self.url = url
        } else {
            self.url = try c.decodeIfPresent(String.self, forKey: .bookingURL) ?? ""
        }

        // Prefer new `address`; fall back to legacy `full_address`.
        if let addr = try c.decodeIfPresent(String.self, forKey: .address) {
            self.address = addr
        } else {
            self.address = try c.decodeIfPresent(String.self, forKey: .fullAddress) ?? ""
        }

        self.location = try c.decode(GeoJSON.self, forKey: .location)

        // Prefer new `locality` / `administrative_area` / `country_code`;
        // fall back to legacy `city` / `state` / `country`.
        if c.contains(.locality) {
            self.locality = try c.decodeIfPresent(String.self, forKey: .locality)
        } else {
            self.locality = try c.decodeIfPresent(String.self, forKey: .city)
        }
        self.subLocality = try c.decodeIfPresent(String.self, forKey: .subLocality)

        if let area = try c.decodeIfPresent(String.self, forKey: .administrativeArea) {
            self.administrativeArea = area
        } else {
            self.administrativeArea = try c.decodeIfPresent(String.self, forKey: .state) ?? ""
        }

        if let code = try c.decodeIfPresent(String.self, forKey: .countryCode) {
            self.countryCode = code
        } else {
            self.countryCode = try c.decodeIfPresent(String.self, forKey: .country) ?? ""
        }

        self.timezone = try c.decodeIfPresent(String.self, forKey: .timezone) ?? ""

        self.units = try c.decodeIfPresent([VenueUnit].self, forKey: .units) ?? []
        self.transitLines = try c.decodeIfPresent([TransitLine].self, forKey: .transitLines) ?? []

        self.features = try c.decodeIfPresent(VenueFeatures.self, forKey: .features) ?? VenueFeatures()

        // Decode `access`; if absent, derive `requiresBooking` from legacy field.
        if let acc = try c.decodeIfPresent(VenueAccess.self, forKey: .access) {
            self.access = acc
        } else {
            let legacy = try c.decodeIfPresent(Bool.self, forKey: .requiresBooking) ?? false
            self.access = VenueAccess(requiresBooking: legacy)
        }

        self.capabilities = try c.decodeIfPresent(VenueCapabilities.self, forKey: .capabilities) ?? VenueCapabilities()

        self.amenities = try c.decodeIfPresent([String].self, forKey: .amenities) ?? []

        // The API serializes timestamps as ISO-8601 strings, not Doubles —
        // route them through the project's `parseDate` helper to match the
        // rest of the codebase (see Club / Event decoders).
        if let createdAtString = try c.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = try parseDate(from: createdAtString)
        } else {
            self.createdAt = nil
        }
        if let updatedAtString = try c.decodeIfPresent(String.self, forKey: .updatedAt) {
            self.updatedAt = try parseDate(from: updatedAtString)
        } else {
            self.updatedAt = nil
        }

        self.owner = try c.decodeIfPresent(Ownership.self, forKey: .owner)
            ?? Ownership(name: "", type: "")
    }

    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(ownerID, forKey: .ownerID)
        try c.encode(name, forKey: .name)
        try c.encode(venueDescription, forKey: .venueDescription)
        try c.encode(availability, forKey: .availability)
        try c.encode(sports, forKey: .sports)
        try c.encode(media, forKey: .media)
        try c.encode(url, forKey: .url)
        try c.encode(address, forKey: .address)
        try c.encode(location, forKey: .location)
        try c.encodeIfPresent(locality, forKey: .locality)
        try c.encodeIfPresent(subLocality, forKey: .subLocality)
        try c.encode(administrativeArea, forKey: .administrativeArea)
        try c.encode(countryCode, forKey: .countryCode)
        try c.encode(timezone, forKey: .timezone)
        try c.encode(units, forKey: .units)
        try c.encode(transitLines, forKey: .transitLines)
        try c.encode(features, forKey: .features)
        try c.encode(access, forKey: .access)
        try c.encode(capabilities, forKey: .capabilities)
        try c.encode(amenities, forKey: .amenities)
        try c.encodeIfPresent(createdAt, forKey: .createdAt)
        try c.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }

    static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id || (lhs.name == rhs.name && lhs.location == rhs.location)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location)
    }
}

extension Venue {
    /// Whether `event` takes place at this venue.
    ///
    /// Matching is deliberately loose: events imported/scraped from other
    /// platforms often arrive without our internal `venueID`, so an id match
    /// alone would miss them. We fall back to a name match against the event's
    /// venue descriptor, which lets an imported event "overlap" onto a venue we
    /// actually have in our catalogue.
    ///
    /// This is the single source of truth for that overlap. Keep the map pin
    /// (`VenueAnnotation.hasEvents`) and the venue detail list
    /// (`VenueEventsView.fieldEvents`) both routed through here so they can't
    /// disagree — i.e. so a venue never shows the "has events" dot without the
    /// matching events appearing inside the venue view.
    func hosts(_ event: Event) -> Bool {
        event.venues.contains { descriptor in
            descriptor.id == id || descriptor.name == name
        }
    }
}

// MARK: - VenueDescriptor

/// Lightweight identity-and-location snapshot of a venue. Embedded on other
/// documents (e.g. `Event.venues`) so we don't have to refetch the full venue
/// just to render a card.
struct VenueDescriptor: Codable, Hashable {

    // New (Go-aligned) fields.
    let venueID: String?
    var name: String?
    var location: GeoJSON?
    var address: String?
    var locality: String?
    var subLocality: String?
    var administrativeArea: String?
    var countryCode: String?

    // MARK: - Legacy field shims
    var id: String? { venueID }
    var fullAddress: String? { address }
    var city: String? { locality }
    var state: String? { administrativeArea }
    var country: String? { countryCode }

    func isInternal() -> Bool {
        return venueID != nil
    }

    func geocode() async -> [CLPlacemark]? {
        let geocoder = CLGeocoder()
        guard let coordinates = self.location?.coordinates, coordinates.count >= 2 else {
            return nil
        }
        let coreLoc = CLLocation(latitude: coordinates[1], longitude: coordinates[0])
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(coreLoc) { placemarks, _ in
                continuation.resume(returning: placemarks ?? [])
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case venueID = "venue_id"
        case name
        case location
        case address
        case locality
        case subLocality = "sub_locality"
        case administrativeArea = "administrative_area"
        case countryCode = "country_code"

        // Legacy keys accepted on decode.
        case id
        case city
        case state
        case country
        case fullAddress = "full_address"
    }

    // New-shape initializer.
    init(
        venueID: String? = nil,
        name: String? = nil,
        location: GeoJSON? = nil,
        address: String? = nil,
        locality: String? = nil,
        subLocality: String? = nil,
        administrativeArea: String? = nil,
        countryCode: String? = nil
    ) {
        self.venueID = venueID
        self.name = name
        self.location = location
        self.address = address
        self.locality = locality
        self.subLocality = subLocality
        self.administrativeArea = administrativeArea
        self.countryCode = countryCode
    }

    // Legacy-shape initializer (kept until call sites migrate).
    init(
        id: String? = nil,
        name: String?,
        city: String?,
        state: String?,
        country: String?,
        location: GeoJSON? = nil,
        fullAddress: String? = nil
    ) {
        self.venueID = id
        self.name = name
        self.location = location
        self.address = fullAddress
        self.locality = city
        self.subLocality = nil
        self.administrativeArea = state
        self.countryCode = country
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // New `venue_id` first, fall back to legacy `id`.
        if let vid = try c.decodeIfPresent(String.self, forKey: .venueID) {
            self.venueID = vid
        } else {
            self.venueID = try c.decodeIfPresent(String.self, forKey: .id)
        }
        self.name = try c.decodeIfPresent(String.self, forKey: .name)
        self.location = try c.decodeIfPresent(GeoJSON.self, forKey: .location)

        if let a = try c.decodeIfPresent(String.self, forKey: .address) {
            self.address = a
        } else {
            self.address = try c.decodeIfPresent(String.self, forKey: .fullAddress)
        }

        if c.contains(.locality) {
            self.locality = try c.decodeIfPresent(String.self, forKey: .locality)
        } else {
            self.locality = try c.decodeIfPresent(String.self, forKey: .city)
        }
        self.subLocality = try c.decodeIfPresent(String.self, forKey: .subLocality)

        if let area = try c.decodeIfPresent(String.self, forKey: .administrativeArea) {
            self.administrativeArea = area
        } else {
            self.administrativeArea = try c.decodeIfPresent(String.self, forKey: .state)
        }

        if let code = try c.decodeIfPresent(String.self, forKey: .countryCode) {
            self.countryCode = code
        } else {
            self.countryCode = try c.decodeIfPresent(String.self, forKey: .country)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(venueID, forKey: .venueID)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(location, forKey: .location)
        try c.encodeIfPresent(address, forKey: .address)
        try c.encodeIfPresent(locality, forKey: .locality)
        try c.encodeIfPresent(subLocality, forKey: .subLocality)
        try c.encodeIfPresent(administrativeArea, forKey: .administrativeArea)
        try c.encodeIfPresent(countryCode, forKey: .countryCode)
    }
}

// MARK: - Responses

/// List response for `GET /venues`.
/// Maps the new `total_venues` / `venues` keys; `fields` is exposed as a
/// computed alias so existing observers keep compiling.
struct VenuesResponse: Codable {
    let totalVenues: Int
    let venues: [Venue]

    enum CodingKeys: String, CodingKey {
        case totalVenues = "total_venues"
        case venues
    }

    init(totalVenues: Int, venues: [Venue]) {
        self.totalVenues = totalVenues
        self.venues = venues
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.venues = try c.decode([Venue].self, forKey: .venues)
        self.totalVenues = try c.decode(Int.self, forKey: .totalVenues)
    }

    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(totalVenues, forKey: .totalVenues)
        try c.encode(venues, forKey: .venues)
    }
}

// MARK: - Write payloads

/// Partial-update payload (PATCH-style). All fields optional so callers send
/// only what they intend to change. Mirrors `models.VenueDao`.
struct VenueDao: Codable {
    var id: String?
    var ownerID: String?
    var name: String?
    var description: String?
    var availability: Availability?
    var sports: [String]?
    var media: [String]?
    var url: String?
    var address: String?
    var location: GeoJSON?
    var locality: String?
    var subLocality: String?
    var administrativeArea: String?
    var countryCode: String?
    var timezone: String?
    /// Unit IDs only — full unit documents live in their own collection.
    var units: [String]?
    /// TransitLine IDs only.
    var transitLines: [String]?
    var features: VenueFeatures?
    var access: VenueAccess?
    var capabilities: VenueCapabilities?
    var amenities: [String]?
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerID = "owner_id"
        case name
        case description
        case availability
        case sports
        case media
        case url
        case address
        case location
        case locality
        case subLocality = "sub_locality"
        case administrativeArea = "administrative_area"
        case countryCode = "country_code"
        case timezone
        case units
        case transitLines = "transit_lines"
        case features
        case access
        case capabilities
        case amenities
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Body for `POST /venues`. Creates the venue + its initial bookable units in
/// one call. Mirrors `models.VenueCreationRequest`.
struct VenueCreationRequest: Codable {
    let venue: VenueDao
    let units: [VenueUnit]
}

// MARK: - Reservations

/// Booking of a specific `VenueUnit` for a time range. See Go model for the
/// pending → confirmed lifecycle (driven by Stripe webhook).
struct VenueReservation: Codable, Identifiable, Hashable {
    let id: String
    let venueID: String
    let venueUnitID: String

    /// Stripe payment-intent / charge id.
    let transactionID: String

    let userID: String
    let clubID: String?
    let organizationID: String?

    let startDate: Date
    let endDate: Date
    let timezone: String

    let currency: String
    let amountPaidMinor: Int64

    let status: String

    /// Only set while `status == .pending`.
    let expiresAt: Date?

    let createdBy: String
    let createdAt: Date
    let updatedAt: Date?

    /// Convenience: parsed status when it matches a known case.
    var parsedStatus: ReservationStatus? { ReservationStatus(rawValue: status) }

    enum CodingKeys: String, CodingKey {
        case id
        case venueID = "venue_id"
        case venueUnitID = "venue_unit_id"
        case transactionID = "transaction_id"
        case userID = "user_id"
        case clubID = "club_id"
        case organizationID = "organization_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case timezone
        case currency
        case amountPaidMinor = "amount_paid_minor"
        case status
        case expiresAt = "expires_at"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.venueID = try c.decode(String.self, forKey: .venueID)
        self.venueUnitID = try c.decode(String.self, forKey: .venueUnitID)
        self.transactionID = try c.decode(String.self, forKey: .transactionID)
        self.userID = try c.decode(String.self, forKey: .userID)
        self.clubID = try c.decodeIfPresent(String.self, forKey: .clubID)
        self.organizationID = try c.decodeIfPresent(String.self, forKey: .organizationID)

        // All Date fields come in as ISO-8601 strings; route through the
        // shared `parseDate` so the decoder accepts every shape we've seen
        // from the backend (see TimeFunctions.swift for the format list).
        self.startDate = try parseDate(from: c.decode(String.self, forKey: .startDate))
        self.endDate = try parseDate(from: c.decode(String.self, forKey: .endDate))

        self.timezone = try c.decode(String.self, forKey: .timezone)
        self.currency = try c.decode(String.self, forKey: .currency)
        self.amountPaidMinor = try c.decode(Int64.self, forKey: .amountPaidMinor)
        self.status = try c.decode(String.self, forKey: .status)

        if let expiresAtString = try c.decodeIfPresent(String.self, forKey: .expiresAt) {
            self.expiresAt = try parseDate(from: expiresAtString)
        } else {
            self.expiresAt = nil
        }

        self.createdBy = try c.decode(String.self, forKey: .createdBy)
        self.createdAt = try parseDate(from: c.decode(String.self, forKey: .createdAt))

        if let updatedAtString = try c.decodeIfPresent(String.self, forKey: .updatedAt) {
            self.updatedAt = try parseDate(from: updatedAtString)
        } else {
            self.updatedAt = nil
        }
    }
}

// MARK: - Helpers

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
