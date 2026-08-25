//
//  NotificationService.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/26/25.
//

import Hermes
import Foundation

class NotificationService {

    private var http: Courrier
    private let decoder = JSONDecoder()

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func GetNotifications() async throws -> NotificationItemListResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/notifications")
        let (data, _) = try await http.Request(.GET, endpoint, headers: headers)
        return try decoder.decode(NotificationItemListResponse.self, from: data)
    }

    func UpdateNotification(request: NotificationUpdateRequest) async throws -> Bool {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/notifications")
        let (_, res) = try await http.Request(.PUT, endpoint, body: EncodeToData(request), headers: headers)
        guard (res as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }

        return true
    }
    
    func declineInvite(for ID: String) async throws -> Bool { return true }
}
