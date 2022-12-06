//
//  EventService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import SwiftUI
import Foundation

class EventService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    func getEvents(long: Double, lat: Double, radius: Int, sport: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/events", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sport", value: sport)
        ])
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: Method.GET)
        return (data, resp)
    }
    
    func createEvent(dao: EventDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/events", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.POST, body: dao)
        return resp
    }
    
    func updateEvent(id: String, dao: EventDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/events/\(id)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.PUT, body: dao)
        return resp
    }
    
    func deleteEvent(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/events/\(id)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.DELETE)
        return resp
    }
    
    func addParticipant(id: String, dao: ParticipantDao) async throws -> (Data,URLResponse) {
        let endpoint = Endpoint(path: "/v1/events/\(id)/participants", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.POST, body: dao)
    }
    
    func removeParticipant(id: String, pid: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/events/\(id)/participants/\(pid)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.DELETE)
        return resp
    }
}
