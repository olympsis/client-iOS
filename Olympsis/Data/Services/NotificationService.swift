//
//  NotificationService.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/26/25.
//

import Hermes
import Firebase
import Foundation

class NotificationService {
    
    private var http: Courrier
    private let decoder = JSONDecoder()
    
    init() {
        #if targetEnvironment(simulator)
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func GetNotifications() async throws -> NotificationItemListResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/notifications")
        let (data, _) = try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
        return try decoder.decode(NotificationItemListResponse.self, from: data)
    }
    
    func UpdateNotification(request: NotificationUpdateRequest) async throws -> Bool {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/notifications")
        let (_, res) = try await http.Request(.PUT, endpoint, body: EncodeToData(request), headers: ["Authorization": token ?? ""])
        guard (res as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }
        
        return true
    }
}
