//
//  VenueService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import Hermes
import SwiftUI
import Foundation

/// Network calls for venue endpoints — search by location and lookup by id.
class VenueService: APIService {

    let http: Courrier
    let decoder = JSONDecoder()
    private let log = Logger(subsystem: "com.olympsis.client", category: "venue_service")

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// GET /v1/venues
    ///
    /// Searches for venues based on location. A 204 means "no venues in this
    /// area" — a valid, empty result, not a failure.
    /// - Parameter longitude: `Double` longitudonal meters of location
    /// - Parameter latitude: `Double` latitudonal memters of location
    /// - Parameter radius: `Int` radius of surface area for search
    /// - Returns: a `[Venue]` an optional venue array containing the venues in that location
    func fetchVenues(longitude: Double, latitude: Double, radius: Int, sports: String) async -> [Venue]? {
        let endpoint = Endpoint("/v1/venues", queryItems: [
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: String(sports)),
            URLQueryItem(name: "limit", value: "200")
        ])
        do {
            let (data, statusCode) = try await requestRaw(.GET, endpoint)
            guard statusCode == 200 else {
                return statusCode == 204 ? [] : nil
            }
            let object = try decoder.decode(VenuesResponse.self, from: data)
            return object.venues
        } catch {
            log.error("Failed to fetch venues: \(error)")
        }
        return nil
    }

    /// GET /v1/venues/{id}
    /// - Parameter id: `String` id of the venue
    /// - Returns: a `Venue` optional in case we fail to get venue
    func fetchVenue(id: String) async -> Venue? {
        do {
            return try await request(.GET, Endpoint("/v1/venues/\(id)"))
        } catch {
            log.error("Failed to fetch venue: \(error.localizedDescription)")
        }
        return nil
    }
}
