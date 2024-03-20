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
    private let tokenStore: SecureStore
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "CHAT") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host)
        self.tokenStore = SecureStore()
    }
    
    func createRoom(room: Room) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint("/chats")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(room), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getRooms(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint("/chats/group/\(id)")
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint("/chats/\(id)")
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func updateRoom(id: String, dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint("/chats/\(id)")
        
        return try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func deleteRoom(id: String) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint("/chats/\(id)")
        
        return try await http.Request(.DELETE, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func joinRoom(id: String, member: ChatMember) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint("/chats/\(id)/join")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(member), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func leaveRoom(id: String) async throws -> URLResponse {
        let endpoint = Hermes.Endpoint("/chats/\(id)/leave")
        
        let (_, resp) = try await http.Request(.POST, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
}


