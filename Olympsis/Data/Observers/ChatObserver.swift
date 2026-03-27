//
//  ChatObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/30/22.
//

import os
import Foundation
#if !DEV
import FirebaseAuth
#endif

class ChatObserver: ObservableObject {

    private let host: String
    private let useHTTPS: Bool
    private let cache = CacheService()
    private let decoder = JSONDecoder()
    private let service = ChatService()
    private let session = URLSession(configuration: .default)
    private let tokenStore = SecureStore()
    private var request: URLRequest? = nil
    private var webSocketTask: URLSessionWebSocketTask? = nil
    private let log = Logger(subsystem: "com.olympsis.client", category: "chat_observer")

    init() {
        let env = AppEnvironment.current
        host = env.chatHost
        useHTTPS = env.useHTTPS
    }
    
    func CreateRoom(group: String, groupType: String, name: String, type: String, userID: String) async -> Room? {
        let room = Room(name: name, type: type, group: GroupModel(id: group, type: groupType), members: [ChatMember(id: nil, userID: userID, status: "live")], history: nil)
        do {
            let (data,resp) = try await service.createRoom(room: room)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let obj = try decoder.decode(Room.self, from: data)
            return obj
        } catch {
            log.error("Failed to create room: \(error.localizedDescription)")
        }
        return nil
    }
    
    func GetRooms(id: String) async -> RoomsResponse? {
        do {
            let (data,resp) = try await service.getRooms(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let obj = try decoder.decode(RoomsResponse.self, from: data)
            return obj
        } catch {
            log.error("Failed to get rooms: \(error.localizedDescription)")
        }
        return nil
    }
    
    func GetRoom(id: String) async -> Room? {
        do {
            let (data,resp) = try await service.getRoom(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let obj = try decoder.decode(Room.self, from: data)
            return obj
        } catch {
            log.error("Failed to get room: \(error.localizedDescription)")
        }
        return nil
    }
    
    func UpdateRoom(id: String, name: String) async -> Room? {
        let dao = RoomDao(name: name)
        do {
            let (data,resp) = try await service.updateRoom(id: id, dao: dao)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let obj = try decoder.decode(Room.self, from: data)
            return obj
        } catch {
            log.error("Failed to update room: \(error.localizedDescription)")
        }
        return nil
    }
    
    func DeleteRoom(id: String) async -> Bool {
        do {
            let (_,resp) = try await service.deleteRoom(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to delete room: \(error.localizedDescription)")
        }
        return false
    }
    
    func JoinRoom(id: String, member: ChatMember) async -> Room? {
        do {
            let (data,resp) = try await service.joinRoom(id: id, member: member)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let obj = try decoder.decode(Room.self, from: data)
            return obj
        } catch {
            log.error("Failed to join room: \(error.localizedDescription)")
        }
        return nil
    }
    
    func LeaveRoom(id: String) async -> Bool {
        do {
            let resp = try await service.leaveRoom(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to leave room: \(error.localizedDescription)")
        }
        return false
    }
    
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
                fatalError("Did not recieve string or data from socket.")
            @unknown default:
                fatalError("Did not recieve string or data from socket.")
            }
        } catch {
            log.error("RecieveError: \(error.localizedDescription)")
        }
        return nil
    }
    
}

