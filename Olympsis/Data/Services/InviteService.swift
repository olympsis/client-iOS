//
//  InviteService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/25/26.
//

import Hermes
import SwiftUI
import Foundation

/// Errors specific to the invite endpoints — the status codes where the
/// invite service attaches its own meaning. Generic failures (400, 404,
/// 5xx, …) surface as `APIServiceError` instead.
enum InviteServiceError: Error {
    /// 409 — the invite is no longer PENDING (a double-tap, or another device
    /// already answered). Treat as "already handled", not a failure.
    case alreadyHandled
    /// 422 — the invite references an id the server no longer recognizes.
    /// Permanent — do not retry.
    case invalidReference
    /// 502 — the join-team/join-event side effect failed transiently; the
    /// invite is still PENDING, so re-sending the same request is safe.
    case retryable
}

/// Network calls for the standalone invite microservice, reached through the
/// API gateway on the main host — the gateway routes `/v1/invites` traffic to
/// the invite service.
///
/// Routes mirror `invite-service/internal/service.go`. The shared `APIService`
/// plumbing handles auth headers, status codes, and decoding; only the
/// invite-specific status meanings are mapped here.
class InviteService: APIService {

    let http: Courrier
    let decoder = JSONDecoder()

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func serviceError(statusCode: Int, message: String) -> Error {
        switch statusCode {
        case 409:
            return InviteServiceError.alreadyHandled
        case 422:
            return InviteServiceError.invalidReference
        case 502:
            return InviteServiceError.retryable
        default:
            return APIServiceError.from(statusCode: statusCode, message: message)
        }
    }

    /// POST /v1/invites
    ///
    /// The server owns `id`, `status` (always starts as PENDING) and both
    /// timestamps — it only reads type/context_id/invitee_id/requestor_id
    /// from the body. Returns the created invite.
    func createInvite(request: CreateInviteRequest) async throws -> InviteResponse {
        // `self.` because the bare name `request` is the parameter here.
        return try await self.request(.POST, Endpoint("/v1/invites"), body: EncodeToData(request), expecting: 201)
    }

    /// GET /v1/invites/{id}
    ///
    /// `id` must be a 24-char hex ObjectID — anything else is a
    /// `.badRequest`; `.notFound` when no invite matches.
    func getInvite(id: String) async throws -> InviteResponse {
        return try await request(.GET, Endpoint("/v1/invites/\(id)"))
    }

    /// GET /v1/invites/user/{user_id}?status=&limit=&cursor=
    ///
    /// Returns one page of the user's invites, newest first.
    /// - status: optional filter (server accepts PENDING/ACCEPTED/DECLINED,
    ///   omitted means all).
    /// - limit: server defaults to 20 and hard-caps at 100.
    /// - cursor: pass the previous page's `nextCursor` to fetch the next
    ///   page; nil/empty fetches the first page. An empty `nextCursor` in
    ///   the response means there are no more pages.
    func getUserInvites(userID: String, status: InviteStatus? = nil, limit: Int? = nil, cursor: String? = nil) async throws -> UserInvitesResponse {
        var queryItems = [URLQueryItem]()
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if let cursor = cursor, !cursor.isEmpty {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }

        return try await request(.GET, Endpoint("/v1/invites/user/\(userID)", queryItems: queryItems))
    }

    /// PATCH /v1/invites/{id}
    ///
    /// Accept or decline a pending invite — the server only allows ACCEPTED
    /// or DECLINED in the body, and on accept it joins the invitee to the
    /// team/event *before* flipping the status. Returns the updated invite,
    /// or throws `.alreadyHandled`, `.retryable`, or `.invalidReference` —
    /// see `InviteServiceError` for what each means to the caller.
    func updateInvite(id: String, request: UpdateInviteRequest) async throws -> InviteResponse {
        return try await self.request(.PATCH, Endpoint("/v1/invites/\(id)"), body: EncodeToData(request))
    }
}
