//
//  UserService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import os
import Hermes
import SwiftUI
import Foundation

/// Network calls for the user endpoints — profile lookup/update, username
/// search/availability, and check-in. The shared `APIService` plumbing
/// handles auth headers, status codes, and decoding.
class UserService: APIService {

    let http: Courrier
    let decoder: JSONDecoder

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    /// GET /v1/users/username?username=
    ///
    /// No status-code check — mirrors the endpoint's pre-migration behavior
    /// of decoding whatever comes back; a malformed body throws from the
    /// decode itself.
    func usernameAvailability(name: String) async throws -> Bool {
        let endpoint = Endpoint("/v1/users/username", queryItems: [URLQueryItem(name: "username", value: name)])
        let (data, _) = try await requestRaw(.GET, endpoint)
        let object = try decoder.decode(UsernameAvailabilityResponse.self, from: data)
        return object.isAvailable
    }

    /// PUT /v1/users/user
    ///
    /// Returns nil on any failure — a non-200 status or a decode error —
    /// callers cannot distinguish the two.
    func updateUserData(update: UserDao) async -> User? {
        do {
            return try await request(.PUT, Endpoint("/v1/users/user"), body: EncodeToData(update))
        } catch {
            return nil
        }
    }

    /// GET /v1/users/search/username?username=
    ///
    /// Empty array on any non-200 status.
    func searchUsersByUsername(username: String) async throws -> [User] {
        let endpoint = Endpoint("/v1/users/search/username", queryItems: [URLQueryItem(name: "username", value: username)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else { return [User]() }
        let object = try decoder.decode(UsersDataResponse.self, from: data)
        return object.users
    }

    /// Returns the top-k users matching `username`, powering the event invitee search.
    /// Hits the template `GET /v1/users?username=` endpoint and decodes a `UsersDataResponse`.
    /// Empty array on any non-200 status.
    func searchUsers(username: String) async throws -> [User] {
        let endpoint = Endpoint("/v1/users", queryItems: [URLQueryItem(name: "username", value: username)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else { return [User]() }
        let object = try decoder.decode(UsersDataResponse.self, from: data)
        return object.users
    }

    /// GET /v1/users/search/user_id?user_id=
    ///
    /// nil on any non-200 status.
    func getUserByUserID(userID: String) async throws -> User? {
        let endpoint = Endpoint("/v1/users/search/user_id", queryItems: [URLQueryItem(name: "user_id", value: userID)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else { return nil }
        return try decoder.decode(User.self, from: data)
    }

    /// GET /v1/users/check-in
    ///
    /// nil on any non-200 status. The 401 branch is split out but behaves
    /// identically to the default case today — needs something smarter in
    /// the future.
    func checkIn() async throws -> CheckIn? {
        let (data, statusCode) = try await requestRaw(.GET, Endpoint("/v1/users/check-in"))
        guard statusCode == 200 else {
            if statusCode == 401 {
                return nil // needs something smarter in the future
            }
            return nil
        }
        return try decoder.decode(CheckIn.self, from: data)
    }
}
