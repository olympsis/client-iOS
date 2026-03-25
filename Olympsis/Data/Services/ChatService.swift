//
//  ChatService.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/1/23.
//

import Hermes
import SwiftUI
import Foundation

class ChatService {

    private var http: Courrier

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.chatHost)
    }

    func createRoom(room: Room) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats")

        return try await http.Request(.POST, endpoint, body: EncodeToData(room), headers: headers)
    }

    func getRooms(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats/group/\(id)")

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getRoom(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)")

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func updateRoom(id: String, dao: RoomDao) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)")

        return try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: headers)
    }

    func deleteRoom(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)")

        return try await http.Request(.DELETE, endpoint, headers: headers)
    }

    func joinRoom(id: String, member: ChatMember) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)/join")

        return try await http.Request(.POST, endpoint, body: EncodeToData(member), headers: headers)
    }

    func leaveRoom(id: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)/leave")

        let (_, resp) = try await http.Request(.POST, endpoint, headers: headers)
        return resp
    }
}
