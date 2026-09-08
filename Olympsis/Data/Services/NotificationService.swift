//
//  NotificationService.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/26/25.
//

import Hermes
import Foundation

/// Which slice of the inbox a listing covers.
///
/// Mirrors notif-service's `ArchiveScope`, and the raw values are the exact
/// `?archived=` strings its handler parses. `.active` deliberately sends no
/// parameter at all — that's already the server's default, and omitting it
/// keeps the common request identical to what this client has always sent.
enum NotificationScope {
    /// Unarchived rows only — the bell view.
    case active
    /// Archived rows only — the archive screen.
    case archived
    /// Archived and active together.
    case all

    /// The `?archived=` value to send, or nil to omit the parameter.
    var queryValue: String? {
        switch self {
        case .active:   return nil
        case .archived: return "only"
        case .all:      return "true"
        }
    }
}

/// Network calls for the notification inbox, served by the standalone
/// notif-service and reached through the API gateway on the main host.
///
/// Routes mirror `notif-service/internal/service.go`. There is no user id in
/// any path: the inbox is always the caller's own, derived from the Firebase
/// token the service verifies. Pages are cursor-based.
class NotificationService {

    private var http: Courrier
    /// The inbox sends RFC3339 timestamps that Go emits with or without
    /// fractional seconds depending on the value, so it needs the lenient
    /// strategy rather than a bare `JSONDecoder`.
    private let decoder = JSONDecoder.notifications

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// GET /v1/notifications?limit=&cursor=&archived=
    ///
    /// The caller's own inbox, newest first. Pass the previous page's
    /// `nextCursor` to page; an empty `nextCursor` means there are no more.
    /// `scope` selects which rows are covered and defaults to the unarchived
    /// inbox.
    func GetNotifications(limit: Int? = nil, cursor: String? = nil, scope: NotificationScope = .active) async throws -> NotificationItemListResponse {
        let headers = try await AppEnvironment.authHeaders()

        var queryItems = [URLQueryItem]()
        if let limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if let cursor, !cursor.isEmpty {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        if let archived = scope.queryValue {
            queryItems.append(URLQueryItem(name: "archived", value: archived))
        }

        let endpoint = Endpoint("/v1/notifications", queryItems: queryItems)
        let (data, _) = try await http.Request(.GET, endpoint, headers: headers)
        return try decoder.decode(NotificationItemListResponse.self, from: data)
    }

    /// PATCH /v1/notifications
    ///
    /// Marks a set of the caller's own notifications
    /// read/unread/archived/unarchived. Ids naming someone else's rows simply
    /// match nothing — the server scopes the update to the token's user.
    func UpdateNotification(request: NotificationUpdateRequest) async throws -> Bool {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/notifications")
        let (_, res) = try await http.Request(.PATCH, endpoint, body: EncodeToData(request), headers: headers)
        guard (res as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }

        return true
    }
}
