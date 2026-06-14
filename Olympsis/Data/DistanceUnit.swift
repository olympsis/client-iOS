//
//  DistanceUnit.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/14/26.
//

import SwiftUI
import Foundation

/// User-facing distance unit for the search radius and venue distances.
///
/// IMPORTANT: the search radius is stored canonically in **miles**
/// everywhere in the app (the events API expects miles and converts to
/// meters server-side; the venues loader converts miles → meters before
/// calling its API). This enum only governs how distances are *presented*
/// and *entered* — it never changes the canonical storage unit, so the
/// existing server-contract logic stays untouched.
///
/// On first launch the effective unit defaults to the device region (see
/// ``deviceDefault``); once the user picks one in Locality settings, that
/// choice is persisted under ``storageKey`` and wins from then on.
enum DistanceUnit: String, CaseIterable, Identifiable {
    case miles
    case kilometers

    var id: String { rawValue }

    /// `@AppStorage` / `UserDefaults` key the chosen unit is persisted to.
    /// An absent value means "user hasn't chosen" → resolve to
    /// ``deviceDefault``.
    static let storageKey = "distance_unit"

    /// Unit appropriate for the device's region, used as the first-run
    /// default. Metric regions get kilometers; everyone else (incl. the
    /// US and UK, which use miles for road distances) gets miles.
    static var deviceDefault: DistanceUnit {
        Locale.current.measurementSystem == .metric ? .kilometers : .miles
    }

    /// Currently-effective unit for non-SwiftUI call sites, read straight
    /// from `UserDefaults`. SwiftUI views should instead use
    /// `@AppStorage(DistanceUnit.storageKey)` so they update reactively
    /// and resolve `nil`/"" via ``resolved(from:)``.
    static var current: DistanceUnit {
        resolved(from: UserDefaults.standard.string(forKey: storageKey))
    }

    /// Resolve a stored raw value (which may be `nil` or empty when the
    /// user hasn't chosen yet) to a concrete unit, falling back to the
    /// device default.
    static func resolved(from rawValue: String?) -> DistanceUnit {
        guard let rawValue, let unit = DistanceUnit(rawValue: rawValue) else {
            return deviceDefault
        }
        return unit
    }

    // MARK: - Presentation

    /// Localized full name for the settings picker ("Miles" / "Kilometers").
    var displayName: String {
        switch self {
        case .miles:      return String(localized: "unit-miles", table: "Settings")
        case .kilometers: return String(localized: "unit-kilometers", table: "Settings")
        }
    }

    /// Localized short abbreviation shown next to values ("mi" / "km").
    var abbreviation: String {
        switch self {
        case .miles:      return String(localized: "unit-miles-abbr", table: "General")
        case .kilometers: return String(localized: "unit-kilometers-abbr", table: "General")
        }
    }

    // MARK: - Conversion
    //
    // Miles is the canonical unit. These helpers convert to/from it so
    // callers can display or accept values in the user's chosen unit while
    // the rest of the app keeps working in miles.

    /// Convert a canonical miles value into this unit (for display / slider).
    func value(fromMiles miles: Double) -> Double {
        switch self {
        case .miles:      return miles
        case .kilometers: return miles * DISTANCE_CONVERTIONS.MILES_TO_KILOMETERS.rawValue
        }
    }

    /// Convert a value entered in this unit back to canonical miles (for storage).
    func miles(fromValue value: Double) -> Double {
        switch self {
        case .miles:      return value
        case .kilometers: return value / DISTANCE_CONVERTIONS.MILES_TO_KILOMETERS.rawValue
        }
    }

    /// Convert a raw meters distance (e.g. `CLLocation.distance(from:)`)
    /// straight into this unit, for one-off distance labels.
    func value(fromMeters meters: Double) -> Double {
        switch self {
        case .miles:      return meters / DISTANCE_CONVERTIONS.MILES_TO_METERS.rawValue
        case .kilometers: return meters / 1000
        }
    }
}
