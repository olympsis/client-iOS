//
//  AppEnvironment.swift
//  Olympsis
//
//  Centralized environment configuration.
//  Determines host, protocol, and auth headers based on compile-time flags.
//
//  Environment is selected via Active Compilation Conditions in Xcode:
//    DEV     → .development  (HTTP to localhost, uses DEV_USER_ID header)
//    STAGING → .staging      (HTTPS to staging host, Firebase auth)
//    else    → .production   (HTTPS to production host, Firebase auth)
//

import Foundation
import FirebaseAuth

enum AppEnvironment {

    case development
    case staging
    case production

    // MARK: - Current environment (resolved at compile time)

    static let current: AppEnvironment = {
        #if DEV
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }()

    // MARK: - Host configuration

    /// Main API host (e.g. "localhost", "api.olympsis.com")
    var apiHost: String {
        switch self {
        case .development:
            return Bundle.main.object(forInfoDictionaryKey: "DEBUG_HOST") as? String ?? "localhost"
        case .staging:
            return Bundle.main.object(forInfoDictionaryKey: "STAGING_HOST") as? String ?? ""
        case .production:
            return Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        }
    }

    /// Chat service host (may include a port, e.g. "localhost:8082")
    var chatHost: String {
        switch self {
        case .development:
            let host = Bundle.main.object(forInfoDictionaryKey: "DEBUG_HOST") as? String ?? "localhost"
            return "\(host):8082"
        case .staging:
            return Bundle.main.object(forInfoDictionaryKey: "STAGING_CHAT") as? String ?? ""
        case .production:
            return Bundle.main.object(forInfoDictionaryKey: "CHAT") as? String ?? ""
        }
    }

    /// Whether to use HTTPS (false only for local development)
    var useHTTPS: Bool {
        switch self {
        case .development: return false
        case .staging:     return true
        case .production:  return true
        }
    }

    // MARK: - Stripe

    /// Stripe publishable key from Info.plist
    var stripePublishableKey: String {
        Bundle.main.object(forInfoDictionaryKey: "STRIPE_PUBLISHABLE_KEY") as? String ?? ""
    }

    // MARK: - Auth headers

    /// Returns the appropriate auth headers for the current environment.
    ///
    /// - Development: `["UserID": <user picked in DevAuth>]` — skips Firebase entirely
    /// - Staging / Production: `["Authorization": <Firebase ID token>]`
    static func authHeaders() async throws -> [String: String] {
        switch current {
        case .development:
            // Whichever dev user this install picked in `DevAuth`, falling back to the
            // `DEV_USER_ID` baked into Info.plist. The selection lives in UserDefaults so
            // several simulators on the same build can each act as a different user.
            return ["UserID": DevUserStore.currentUserID]
        case .staging, .production:
            let token = try await Auth.auth().currentUser?.getIDToken()
            return ["Authorization": token ?? ""]
        }
    }

    /// Returns auth headers merged with additional headers.
    ///
    /// Useful for services like UploadService that need extra headers (e.g. `X-Filename`).
    static func authHeaders(merging extra: [String: String]) async throws -> [String: String] {
        var headers = try await authHeaders()
        for (key, value) in extra {
            headers[key] = value
        }
        return headers
    }
}
