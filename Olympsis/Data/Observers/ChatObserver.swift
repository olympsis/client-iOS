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
    
    private let log: Logger
    private let host: String
    private var timer: Timer
    private var intervals: Double
    private let cache: CacheService
    private let decoder: JSONDecoder
    private let service: ChatService
    private let session: URLSession
    private var request: URLRequest? = nil
    private var webSocketTask: URLSessionWebSocketTask? = nil
    
    init() {
        log = Logger()
        timer = Timer()
        intervals = 15
        cache = CacheService()
        decoder = JSONDecoder()
        service = ChatService()
        session = URLSession(configuration: .default)
        host = Bundle.main.object(forInfoDictionaryKey: "CHAT") as? String ?? ""
    }
    
    func CreateRoom(club: String, name: String, uuid: String) async -> Room? {
        let dao = RoomDao(owner: club, name: name, type: "group", members: [ChatMember(id: "", uuid: uuid, status: "live")])
        do {
            let (data,resp) = try await service.createRoom(dao: dao)
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
    
    func JoinRoom(id: String) async -> Room? {
        do {
            let (data,resp) = try await service.joinRoom(id: id)
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
        let token = ""
        self.request = URLRequest(url: URL(string: "wss://\(host)/v1/chats/\(id)/ws")!)
        guard var request = request else {
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue("chat.olympsis.com", forHTTPHeaderField: "Host")
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
                print("failed to send message: " + error.localizedDescription)
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
            print("RecieveError: " + error.localizedDescription)
        }
        return nil
    }
    
}

