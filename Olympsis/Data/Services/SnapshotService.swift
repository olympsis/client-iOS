//
//  SnapshotService.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/27/26.
//

import Hermes
import SwiftUI
import Foundation

class SnapshotService {

    private var http: Courrier

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// Response model for the map snapshot endpoint.
    struct MapSnapshotResponse: Decodable {
        let url: String
    }

    /// Fetches a map snapshot URL for the given venue location.
    /// - Parameter name: Comma-separated latitude and longitude string (e.g. "40.7608,-111.8910")
    /// - Returns: The URL string pointing to the snapshot image
    func getMapSnapshotURL(name: String) async throws -> String {
        let headers = try await AppEnvironment.authHeaders(merging: ["Content-Type": "application/json"])
        let endpoint = Endpoint("/v1/map-snapshot", queryItems: [
            URLQueryItem(name: "center", value: name)
        ])
        let (data, _): (Data, URLResponse) = try await http.Request(.GET, endpoint, headers: headers)
        let response = try JSONDecoder().decode(MapSnapshotResponse.self, from: data)
        return response.url
    }
}
