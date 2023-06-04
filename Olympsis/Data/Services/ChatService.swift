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
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key, token: tokenStore.fetchTokenFromKeyChain())
    }
    
    func createRoom(dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint(path: "/chats", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(dao))
    }
    
    func getRooms(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/chats/club/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func updateRoom(id: String, dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func deleteRoom(id: String) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func joinRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)/join", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: Method.POST, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func leaveRoom(id: String) async throws -> URLResponse {
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)/leave", queryItems: [
            URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .POST, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
}


