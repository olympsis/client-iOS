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
    
    func getClubs(c: String, s: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/clubs", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: Method.GET)
        return (data, resp)
    }
    
    func getClub(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: Method.GET)
        return data
    }
    
    // TODO: Add club to body need to create a club DAO
    func createClub(dao: ClubDao) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: Method.POST, body: dao)
        return data
    }
    
    // TODO: FOR ADMINS
    
    func createClubApplication(id: String) async throws -> Bool {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)/applications", queryItems: [URLQueryItem]())
     
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.POST)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func deleteClubApplication(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/clubs/applications/\(id)", queryItems: [URLQueryItem]())
     
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: Method.DELETE)
        return data
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)/applications", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: Method.GET)
        return (data, resp)
    }
    
    func updateApplication(id: String, appId: String, dao: UpdateApplicationDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)/applications/\(appId)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.PUT, body: dao)
        return resp
    }
    
    func changeRank(id: String, memberId: String, dao: ChangeRankDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)/members/\(memberId)/rank", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.PUT, body: dao)
        return resp
    }
    
    func kickMember(id: String, memberId: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/clubs/\(id)/members/\(memberId)/kick", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.PUT)
        return resp
    }
}

