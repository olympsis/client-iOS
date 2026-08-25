//
//  APIService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/25/26.
//

import Hermes
import Foundation

/// Errors shared by every `APIService` conformer, produced by the default
/// `serviceError(statusCode:message:)` mapping. `message` carries the
/// server's `{"msg": "..."}` text when the response had one.
enum APIServiceError: Error {
    /// 400 — the request was malformed.
    case badRequest(message: String)
    /// 401 — missing/invalid auth.
    case unauthorized
    /// 403 — authenticated but not allowed.
    case forbidden
    /// 404 — no such resource.
    case notFound
    /// 409 — the resource is in a state that rejects this change.
    case conflict(message: String)
    /// 422 — the request was well-formed but semantically unusable.
    case unprocessable(message: String)
    /// 500 and above — something broke server-side.
    case serverError(statusCode: Int, message: String)
    /// Any status we have no mapping for.
    case unexpected(statusCode: Int, message: String)

    static func from(statusCode: Int, message: String) -> APIServiceError {
        switch statusCode {
        case 400:
            return .badRequest(message: message)
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 409:
            return .conflict(message: message)
        case 422:
            return .unprocessable(message: message)
        case 500...:
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .unexpected(statusCode: statusCode, message: message)
        }
    }
}

/// The backend's error payloads are `{"msg": "..."}` across services.
private struct ServerMessage: Decodable {
    let msg: String
}

/// Shared plumbing for HTTP services: auth headers, the Hermes >500 catch,
/// status-code checking, and response decoding. A service conforms by
/// providing its `Courrier` and a `JSONDecoder`; endpoint methods then
/// collapse to a single `request(...)` call each.
protocol APIService {
    /// Courrier pointed at this service's host.
    var http: Courrier { get }
    var decoder: JSONDecoder { get }

    /// Maps a failed status code onto an error. The default implementation
    /// covers the common codes via `APIServiceError.from`; a service
    /// overrides this where a code carries endpoint-specific meaning
    /// (e.g. invites: 409 = "already handled").
    ///
    /// IMPORTANT: this must stay declared here in the protocol, not just in
    /// the extension. Protocol-extension methods are statically dispatched —
    /// if this were extension-only, the generic `request` helper would call
    /// the default and silently ignore a service's override.
    func serviceError(statusCode: Int, message: String) -> Error
}

extension APIService {

    func serviceError(statusCode: Int, message: String) -> Error {
        APIServiceError.from(statusCode: statusCode, message: message)
    }

    /// One call: auth headers → request → status check → decode.
    ///
    /// Hermes throws `NetworkError.serverError` itself for any status above
    /// 500 — before we ever see the response — so that range is folded into
    /// `serviceError` in the catch. Everything else (4xx and 500) comes back
    /// as data and is checked against `expected`. Transport failures
    /// (timeout, no internet, …) still surface as Hermes `NetworkError`s.
    func request<T: Decodable>(_ method: Hermes.Method, _ endpoint: Hermes.Endpoint, body: Data? = nil, expecting expected: Int = 200) async throws -> T {
        let headers = try await AppEnvironment.authHeaders()

        let data: Data
        let resp: URLResponse
        do {
            (data, resp) = try await http.Request(method, endpoint, body: body, headers: headers)
        } catch NetworkError.serverError(let statusCode) {
            throw serviceError(statusCode: statusCode, message: "")
        }

        let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard statusCode == expected else {
            throw serviceError(statusCode: statusCode, message: serverMessage(from: data))
        }

        return try decoder.decode(T.self, from: data)
    }

    /// Pulls the `msg` field out of an error body, empty when there is none.
    func serverMessage(from data: Data) -> String {
        (try? decoder.decode(ServerMessage.self, from: data))?.msg ?? ""
    }
}
