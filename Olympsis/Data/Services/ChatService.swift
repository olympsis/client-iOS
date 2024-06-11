//
//  ChatService.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/1/23.
//

import Hermes
import SwiftUI
import Foundation
import FirebaseAuth

class ChatService {
    
    private var http: Courrier
    
    init() {
        
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost:8082")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "CHAT") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func createRoom(room: Room) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(room), headers: ["Authorization": token ?? ""])
    }
    
    func getRooms(id: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats/group/\(id)")
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func getRoom(id: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)")
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func updateRoom(id: String, dao: RoomDao) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)")
        
        return try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": token ?? ""])
    }
    
    func deleteRoom(id: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)")
        
        return try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func joinRoom(id: String, member: ChatMember) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)/join")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(member), headers: ["Authorization": token ?? ""])
    }
    
    func leaveRoom(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/v1/chats/\(id)/leave")
        
        let (_, resp) = try await http.Request(.POST, endpoint, headers: ["Authorization": token ?? ""])
        return resp
    }
}


