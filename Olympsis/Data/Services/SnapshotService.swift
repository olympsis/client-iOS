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

    /// Fetches a map snapshot image for the given venue location.
    /// - Parameter name: Comma-separated latitude and longitude string (e.g. "40.7608,-111.8910")
    /// - Returns: Tuple of raw image `Data` and `URLResponse`
    func getMapSnapshot(name: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders(merging: ["Content-Type": "image/png"])
        let endpoint = Endpoint("/v1/map-snapshot", queryItems: [
            URLQueryItem(name: "center", value: name)
        ])
        return try await http.Request(.GET, endpoint, headers: headers)
    }
}
