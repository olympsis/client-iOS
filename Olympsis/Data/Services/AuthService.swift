//
//  AuthService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import Hermes
import SwiftUI
import Foundation
import FirebaseAuth
import AuthenticationServices

/// Auth endpoints on the main API host, plus the Firebase Sign-In-With-Apple
/// flow that feeds them. `register`/`login` run before the caller has a
/// session; `updateUser`/`deleteAccount` run after — the shared
/// `request`/`requestRaw` helpers add auth headers uniformly either way (see
/// `AppEnvironment.authHeaders`).
extension USER_STATUS {

    /// Where a returning Apple credential should land.
    ///
    /// Someone who quit halfway through signup used to be sent back to the
    /// first step every time, which asks again for details the server already
    /// has. Deciding from the cached profile lets them resume where they
    /// stopped. Birthdate and gender are deliberately not required for
    /// `.returning`: accounts created before those were stored server-side
    /// must not be pushed back into signup.
    static func resumeStatus(for user: User?) -> USER_STATUS {
        guard let user else {
            return .not_finished
        }

        let hasUsername = !(user.username ?? "").isEmpty && !user.hasPlaceholderUsername
        let hasSports = !(user.sports ?? []).isEmpty
        let hasVisibility = !(user.visibility ?? "").isEmpty

        if hasUsername && hasSports && hasVisibility {
            return .returning
        }
        if hasUsername && user.gender != nil {
            return .needs_sports
        }
        return .not_finished
    }
}

class AuthService: APIService {

    let http: Courrier
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    let cacheService = CacheService()
    let log = Logger(subsystem: "com.olympsis.client", category: "auth_service")

    /// Set inside `handleSignInWithApple` to record whether the Apple
    /// credential looked like a first-time or returning user.
    @AppStorage("auth_type") private var authType: USER_STATUS?

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// POST /v1/auth/register
    ///
    /// Creates the server-side user record for a newly Firebase-authenticated
    /// account. Fire-and-forget: only a 200 is treated as success, nothing is
    /// decoded, and a non-200 status is not treated as an error.
    func register(firstName: String, lastName: String, email: String, token: String) async throws {
        let req = AuthRequest(firstName: firstName, lastName: lastName, email: email, token: token)
        let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/auth/register"), body: EncodeToData(req))
        guard statusCode == 200 else {
            return
        }
    }

    /// POST /v1/auth/login
    ///
    /// - 404: no server-side user record exists yet for this token — the
    ///   caller should route to the finish-signup flow.
    /// - otherwise: decodes the returned `User` and caches it locally.
    func login(token: String) async throws -> USER_STATUS {
        let req = AuthRequest(token: token)
        let (data, statusCode) = try await requestRaw(.POST, Endpoint("/v1/auth/login"), body: EncodeToData(req))

        if statusCode == 404 {
            return .not_finished
        }

        let object = try decoder.decode(User.self, from: data)

        // store user data
        cacheService.cacheUser(user: object)
        return .returning
    }

    /// PUT /v1/auth/modify
    func updateUser(_ dao: AuthUserDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/auth/modify"), body: EncodeToData(dao))
        guard statusCode == 200 else {
            return false
        }
        return true
    }

    /// DELETE /v1/auth/delete
    func deleteAccount() async throws -> Bool {
        // clear server data
        let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/auth/delete"))
        guard statusCode == 200 else {
            log.error("Failed to delete remote user data")
            return false
        }
        return true
    }

    func handleSignInWithApple(result: Result<ASAuthorization, Error>, nonce: String?) async throws -> USER_STATUS {

        switch result {
        case .success(let authorization):
            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = nonce else {
                    log.error("Invalid state: A login callback was received, but no login request was sent.")
                    return .unknown
                }

                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {

                    /*
                        New User
                     */
                    self.authType = .new
                    log.debug("New user signing in")
                    guard let idToken = appleIdCredential.identityToken
                              .flatMap({ String(data: $0, encoding: .utf8) }) else {
                        return USER_STATUS.unknown
                    }

                    // Name/email may be nil if Apple doesn't return them
                    let email = appleIdCredential.email ?? ""
                    let firstName = appleIdCredential.fullName?.givenName ?? ""
                    let lastName = appleIdCredential.fullName?.familyName ?? ""

                    let creds = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: appleIdCredential.fullName)

                    do {
                        try await Auth.auth().signIn(with: creds)
                        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
                            return USER_STATUS.unknown
                        }

                        try await register(firstName: firstName, lastName: lastName, email: email, token: token)

                        return USER_STATUS.new
                    } catch {
                        log.error("Authentication Failed: \(error.localizedDescription)")
                        return USER_STATUS.unknown
                    }

                } else {

                    /*
                        Existing User
                     */
                    self.authType = .returning
                    log.debug("Existing user logging in")
                    guard let idToken = appleIdCredential.identityToken
                              .flatMap({ String(data: $0, encoding: .utf8) }) else {
                        return USER_STATUS.unknown
                    }

                    let creds = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)

                    do {
                        try await Auth.auth().signIn(with: creds)
                        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
                            return USER_STATUS.unknown
                        }

                        let status = try await login(token: token)

                        // user not found on server
                        if status == .not_finished {
                            return USER_STATUS.not_finished
                        }

                        return USER_STATUS.resumeStatus(for: cacheService.fetchUser())
                    } catch {
                        log.error("Authentication Failed: \(error.localizedDescription)")
                        return USER_STATUS.unknown
                    }
                }
            }
        case .failure(let error):
            log.error("SignIn with Apple was cancelled or an error occured: \(error)")
            throw error
        }
        return USER_STATUS.unknown
    }
}
