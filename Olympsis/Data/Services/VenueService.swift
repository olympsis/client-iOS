//
//  FieldService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Hermes
import SwiftUI
import Foundation

class VenueService {

    private var http: Courrier

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func getVenues(long: Double, lat: Double, radius: Int, sports: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/venues", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: String(sports))
        ])

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getVenue(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/venues/\(id)")
        return try await http.Request(.GET, endpoint, headers: headers)
    }
}
