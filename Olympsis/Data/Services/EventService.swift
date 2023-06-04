//
//  EventService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Hermes
import SwiftUI
import Foundation

class EventService {
    
    private var http: Courrier
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key)
    }
    
    func getEvents(long: Double, lat: Double, radius: Int, sports: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint(path: "/events", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports)
        ])
        
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getEvent(id: String) async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/events/\(id)", queryItems: [URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func createEvent(event: Event) async throws -> (Data,URLResponse) {
        let endpoint = Endpoint(path: "/events")
        
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(event), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func updateEvent(id: String, dao: EventDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/events/\(id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func deleteEvent(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/events/\(id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func addParticipant(id: String, dao: ParticipantDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/events/\(id)/participants", queryItems: [URLQueryItem]())
        
        let (_,resp) = try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func removeParticipant(id: String, pid: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/events/\(id)/participants/\(pid)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .DELETE,  headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
}
