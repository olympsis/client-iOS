//
//  ChatObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/30/22.
//

import os
import SocketIO
import Foundation

class ChatObserver: ObservableObject {
    
    private let host: String
    private var timer = Timer()
    private var intervals: Double = 15
    private let cache = CacheService()
    private let decoder = JSONDecoder()
    private let service = ChatService()
    private let session = URLSession(configuration: .default)
    private let tokenStore = TokenStore()
    private var request: URLRequest? = nil
    private var webSocketTask: URLSessionWebSocketTask? = nil
    private let log = Logger(subsystem: "com.coronislabs.olympsis", category: "chat_observer")
    
    init() {
        host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
    }
    
    func CreateRoom(club: String, name: String, type: String, uuid: String) async -> Room? {
        let room = Room(name: name, type: type, clubID: club, members: [ChatMember(id: "", uuid: uuid, status: "live")], history: nil)
        do {
            let (data,resp) = try await service.createRoom(room: room)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let obj = try decoder.decode(Room.self, from: data)
            return obj
        } catch (let err) {
            print(err)
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
        } catch (let err) {
            print(err)
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
        } catch (let err) {
            print(err)
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
        } catch (let err) {
            print(err)
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
        } catch (let err) {
            print(err)
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
        } catch (let err) {
            print(err)
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
        } catch (let err) {
            print(err)
        }
        return false
    }
    
    func InitiateSocketConnection(id: String) async {
        let token = tokenStore.fetchTokenFromKeyChain()
        self.request = URLRequest(url: URL(string: "wss://\(host)/chats/\(id)/ws")!)
        guard var request = request else {
            return
        }
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue("permessage-deflate; client_max_window_bits", forHTTPHeaderField: "Sec-WebSocket-Extensions")
        request.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
        self.webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        log.log("Socket Connection Initiated")
    }
    
    func Ping() {
        timer = Timer.scheduledTimer(withTimeInterval: intervals, repeats: true) {[weak self] _ in
            self?.log.log("PING")
            self?.webSocketTask?.sendPing { err in
                if let e = err {
                    print("Failed to send Ping: \(e)")
                } else {
                    self?.log.log("PONG")
                }
            }
        }
    }
    
    func CloseSocketConnection() async {
        timer.invalidate()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        log.log("Socket Connection Closed")
    }
    
    func SendMessage(msg: Message) async -> Bool {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(msg) {
            let message = URLSessionWebSocketTask.Message.data(data)
            do {
                try await webSocketTask?.send(message)
                return true
            } catch {
                log.error("failed to send message: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
    
    func ReceiveMessage() async -> Message? {
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
            timer.invalidate()
            log.error("RecieveError: \(error.localizedDescription)")
        }
        return nil
    }
    
}

