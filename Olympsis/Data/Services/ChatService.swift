//
//  ChatService.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/1/23.
//

import os
import SwiftUI
import Foundation

class ChatService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService(chat: true)
    }
    
    let urlSession = URLSession.shared
    
    
    func createRoom(dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Endpoint(path: "/v1/chats", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.POST, body: dao)
    }
    
    func getRooms(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/chats/club/\(id)", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.GET)
    }
    
    func getRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.GET)
    }
    
    func updateRoom(id: String, dao: RoomDao) async throws -> (Data, URLResponse) {
        
        let endpoint = Endpoint(path: "/v1/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.PUT, body: dao)
    }
    
    func deleteRoom(id: String) async throws -> (Data, URLResponse) {
        
        let endpoint = Endpoint(path: "/v1/chats/\(id)", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.DELETE)
    }
    
    func joinRoom(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/chats/\(id)/join", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.POST)
    }
    
    func leaveRoom(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/chats/\(id)/leave", queryItems: [
            URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.POST)
        return resp
    }
}


