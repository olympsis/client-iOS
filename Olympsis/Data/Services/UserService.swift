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

    /// GET /v1/users?user_id=
    ///
    /// Replaces `/v1/users/search/user_id`, a path that existed on neither the
    /// server nor the gateway — the old route was `/v1/users/search/uuid` — so
    /// every call 404'd and this silently returned nil. Single-user lookups now
    /// hang off the `user_id` query param on `/v1/users`, which returns the same
    /// user object, making this a URL change only.
    ///
    /// The server withholds account-private fields (notification devices and
    /// preference, blocked users, last location) when the caller isn't the user
    /// being looked up, and trims clubs/sports/organizations for a private
    /// profile. All of those are already optional on `User`.
    ///
    /// nil on any non-200 status — 404 when no such user exists.
    func getUserByUserID(userID: String) async throws -> User? {
        let endpoint = Endpoint("/v1/users", queryItems: [URLQueryItem(name: "user_id", value: userID)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else { return nil }
        return try decoder.decode(User.self, from: data)
    }

    /// GET /v1/users/check-in
    ///
    /// Throws rather than returning nil so the caller can tell the failures
    /// apart: a 401 means the session is genuinely gone, while a 5xx or a
    /// transport error means the app should say so and offer a retry instead
    /// of signing the user out.
    func checkIn() async throws -> CheckIn {
        return try await request(.GET, Endpoint("/v1/users/check-in"))
    }
}
