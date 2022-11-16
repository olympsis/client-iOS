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
    // TODO: FOR ADMINS
    func getClubApplications() async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.GET)
        return data
    }
    
    func CreateClubApplication(req: ClubApplicationRequestDao) async throws -> Bool {
        let endpoint = Endpoint(path: "/v1/clubs/applications", queryItems: [URLQueryItem]())
     
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (_, resp) = try await http.request(endpoint: endpoint, method: Method.POST, body: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func DeleteClubApplication(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs/applications/\(id)", queryItems: [URLQueryItem]())
     
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.DELETE)
        return data
    }
}

