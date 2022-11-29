//
//  ClubService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import SwiftUI
import Foundation

class ClubService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    func getClubs() async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs", queryItems: [
            URLQueryItem(name: "country", value: "United States of America"),
            URLQueryItem(name: "state", value: "Utah")
        ])
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.GET)
        return data
    }
    
    func getClub(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.GET)
        return data
    }
    
    // TODO: Add club to body need to create a club DAO
    func createClub(dao: ClubDao) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.POST, body: dao)
        return data
    }
    
    // TODO: FOR ADMINS
    
    func createClubApplication(req: ClubApplicationRequestDao) async throws -> Bool {
        let endpoint = Endpoint(path: "/v1/clubs/applications", queryItems: [URLQueryItem]())
     
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (_, resp) = try await http.request(endpoint: endpoint, method: Method.POST, body: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func deleteClubApplication(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs/applications/\(id)", queryItems: [URLQueryItem]())
     
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.DELETE)
        return data
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)/applications", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, resp) = try await http.request(endpoint: endpoint, method: Method.GET)
        return (data, resp)
    }
    
    func updateApplication(id: String, dao: UpdateApplicationDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/clubs/applications/\(id)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        let (_, resp) = try await http.request(endpoint: endpoint, method: Method.PUT, body: dao)
        return resp
    }
}

