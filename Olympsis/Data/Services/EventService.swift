//
//  EventService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Hermes
import SwiftUI
import Foundation
import FirebaseAuth

class EventService {
    
    private var http: Courrier
    
    init() {
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func location(long: Double, lat: Double, radius: Int, sports: String, status: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/events/location", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports),
            URLQueryItem(name: "status", value: status),
        ])
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func getEvents(long: Double, lat: Double, radius: Int, sports: String, status: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/events", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports),
            URLQueryItem(name: "status", value: status),
        ])
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func getEventsByField(id: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Hermes.Endpoint("/events/field/\(id)")
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func getEvent(id: String) async throws -> (Data, URLResponse){
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)", queryItems: [URLQueryItem]())
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func createEvent(event: EventDao) async throws -> (Data,URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events")
        return try await http.Request(.POST, endpoint, body: EncodeToData(event), headers: ["Authorization": token ?? ""])
    }
    
    func updateEvent(id: String, dao: EventDao) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func deleteEvent(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func addParticipant(id: String, _ participant: Participant) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)/participants", queryItems: [URLQueryItem]())
        
        let (_,resp) = try await http.Request(.POST, endpoint, body: EncodeToData(participant), headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func removeParticipant(id: String, pid: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)/participants/\(pid)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.DELETE, endpoint,  headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func notifyParticipants(id: String, notif: Notification) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)/notify/participants", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(notif), headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func notifyClubMembers(id: String, notif: Notification) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/events/\(id)/notify/club", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(notif), headers: ["Authorization": token ?? ""])
        return resp
    }
}
