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
        self.http = Courrier(host: host, apiKey: key, token: tokenStore.FetchTokenFromKeyChain())
    }
    
    func createRoom(dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint(path: "/chats", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(dao))
    }
    
    func getRooms(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/chats/club/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .GET)
    }
    
    func getRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .GET)
    }
    
    func updateRoom(id: String, dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(dao))
    }
    
    func deleteRoom(id: String) async throws -> (Data, URLResponse) {
        
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .DELETE)
    }
    
    func joinRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)/join", queryItems: [
            URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: Method.POST)
    }
    
    func leaveRoom(id: String) async throws -> URLResponse {
        let endpoint = Hermes.Endpoint(path: "/chats/\(id)/leave", queryItems: [
            URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .POST)
        return resp
    }
}


