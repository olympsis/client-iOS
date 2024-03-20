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
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host)
    }
    
    func location(long: Double, lat: Double, radius: Int, sports: String, status: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint("/events/location", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports),
            URLQueryItem(name: "status", value: status),
        ])
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getEvents(long: Double, lat: Double, radius: Int, sports: String, status: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint("/events", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports),
            URLQueryItem(name: "status", value: status),
        ])
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getEventsByField(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Hermes.Endpoint("/events/field/\(id)")
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getEvent(id: String) async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/events/\(id)", queryItems: [URLQueryItem]())
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func createEvent(event: EventDao) async throws -> (Data,URLResponse) {
        let endpoint = Endpoint("/events")
        return try await http.Request(.POST, endpoint, body: EncodeToData(event), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func updateEvent(id: String, dao: EventDao) async throws -> URLResponse {
        let endpoint = Endpoint("/events/\(id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func deleteEvent(id: String) async throws -> URLResponse {
        let endpoint = Endpoint("/events/\(id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func addParticipant(id: String, _ participant: Participant) async throws -> URLResponse {
        let endpoint = Endpoint("/events/\(id)/participants", queryItems: [URLQueryItem]())
        
        let (_,resp) = try await http.Request(.POST, endpoint, body: EncodeToData(participant), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func removeParticipant(id: String, pid: String) async throws -> URLResponse {
        let endpoint = Endpoint("/events/\(id)/participants/\(pid)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.DELETE, endpoint,  headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func notifyParticipants(id: String, notif: Notification) async throws -> URLResponse {
        let endpoint = Endpoint("/events/\(id)/notify/participants", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(notif), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func notifyClubMembers(id: String, notif: Notification) async throws -> URLResponse {
        let endpoint = Endpoint("/events/\(id)/notify/club", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(notif), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
}
