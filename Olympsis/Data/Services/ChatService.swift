//
//  ChatService.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/1/23.
//

import os
import Hermes
import Foundation

/// Network calls for the chat microservice, plus the stateful websocket
/// connection used for live messages in a room.
///
/// The HTTP methods mirror the old chat observer's public surface exactly:
/// they swallow errors (log + return nil/false) instead of throwing, so
/// callers only ever branch on presence/success. The websocket half
/// (`initiateSocketConnection`/`sendMessage`/`receiveMessage`/…) was moved
/// over as-is — this service intentionally holds live connection state,
/// unlike the other `APIService` conformers.
class ChatService: APIService {

    let http: Courrier
    let decoder = JSONDecoder()

    private let host: String
    private let useHTTPS: Bool
    private let session = URLSession(configuration: .default)
    private var request: URLRequest? = nil
    private var webSocketTask: URLSessionWebSocketTask? = nil
    private let log = Logger(subsystem: "com.olympsis.client", category: "chat_service")

    init() {
        let env = AppEnvironment.current
        host = env.chatHost
        useHTTPS = env.useHTTPS
        http = Courrier(useHTTPS ? .HTTPS : .HTTP, host: host)
    }

    // MARK: - HTTP

    /// POST /v1/chats — expects 201 on success.
    func CreateRoom(group: String, groupType: String, name: String, type: String, userID: String) async -> Room? {
        let room = Room(name: name, type: type, group: GroupModel(id: group, type: groupType), members: [ChatMember(id: nil, userID: userID, status: "live")], history: nil)
        do {
            return try await request(.POST, Endpoint("/v1/chats"), body: EncodeToData(room), expecting: 201)
        } catch {
            log.error("Failed to create room: \(error.localizedDescription)")
        }
        return nil
    }

    /// GET /v1/chats/group/{id} — all rooms belonging to a club/organization.
    func GetRooms(id: String) async -> RoomsResponse? {
        do {
            return try await request(.GET, Endpoint("/v1/chats/group/\(id)"))
        } catch {
            log.error("Failed to get rooms: \(error.localizedDescription)")
        }
        return nil
    }

    /// GET /v1/chats/{id}
    func GetRoom(id: String) async -> Room? {
        do {
            return try await request(.GET, Endpoint("/v1/chats/\(id)"))
        } catch {
            log.error("Failed to get room: \(error.localizedDescription)")
        }
        return nil
    }

    /// PUT /v1/chats/{id} — expects 201 on success.
    func UpdateRoom(id: String, name: String) async -> Room? {
        let dao = RoomDao(name: name)
        do {
            return try await request(.PUT, Endpoint("/v1/chats/\(id)"), body: EncodeToData(dao), expecting: 201)
        } catch {
            log.error("Failed to update room: \(error.localizedDescription)")
        }
        return nil
    }

    /// DELETE /v1/chats/{id}
    func DeleteRoom(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/chats/\(id)"))
            return statusCode == 200
        } catch {
            log.error("Failed to delete room: \(error.localizedDescription)")
        }
        return false
    }

    /// POST /v1/chats/{id}/join — expects 201 on success.
    func JoinRoom(id: String, member: ChatMember) async -> Room? {
        do {
            return try await request(.POST, Endpoint("/v1/chats/\(id)/join"), body: EncodeToData(member), expecting: 201)
        } catch {
            log.error("Failed to join room: \(error.localizedDescription)")
        }
        return nil
    }

    /// POST /v1/chats/{id}/leave
    func LeaveRoom(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/chats/\(id)/leave"))
            return statusCode == 200
        } catch {
            log.error("Failed to leave room: \(error.localizedDescription)")
        }
        return false
    }

    // MARK: - Websocket

    func initiateSocketConnection(id: String) async {
        let scheme = useHTTPS ? "wss" : "ws"
        self.request = URLRequest(url: URL(string: "\(scheme)://\(host)/v1/chats/\(id)/ws")!)

        guard var request = request else {
            return
        }

        // Set up request headers
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue("permessage-deflate; client_max_window_bits", forHTTPHeaderField: "Sec-WebSocket-Extensions")
        request.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")

        self.webSocketTask = session.webSocketTask(with: request)
        self.webSocketTask?.maximumMessageSize = 1024 * 1024 // 1MB
        webSocketTask?.resume()

        log.info("Socket Connection Initiated!")
        await self.authenticateWebSocket()
    }

    /// Authenticates the websocket connection.
    /// In DEV mode, sends the DEV_USER_ID. In staging/production, sends the Firebase token.
    func authenticateWebSocket() async {
        do {
            let encoder = JSONEncoder()
            let headers = try await AppEnvironment.authHeaders()
            if let data = try? encoder.encode(headers) {
                let message = URLSessionWebSocketTask.Message.data(data)
                try await self.webSocketTask?.send(message)
                log.info("Socket Connection Authenticated!")
            }
        } catch {
            log.error("Failed to authenticate websocket: \(error.localizedDescription)")
        }
    }

    func closeSocketConnection() async {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        log.info("Socket Connection Closed!")
    }

    func sendMessage(msg: Message) async -> Bool {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(msg) {
            let message = URLSessionWebSocketTask.Message.data(data)
            do {
                try await webSocketTask?.send(message)
                return true
            } catch {
                log.error("Failed to send message: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }

    func receiveMessage() async -> Message? {
        do {
            let message = try await webSocketTask?.receive()
            let decoder = JSONDecoder()
            switch message {
            case .string(let str):
                let d = Data(str.utf8)
                if let msg = try? decoder.decode(Message.self, from: d) {
                  return msg
                }
            case .data(let data):
                if let msg = try? decoder.decode(Message.self, from: data) {
                  return msg
                }
            case .none:
                log.error("Did not recieve string or data from socket.")
            @unknown default:
                log.error("Did not recieve string or data from socket.")
            }
        } catch {
            log.error("RecieveError: \(error.localizedDescription)")
        }
        return nil
    }
}
