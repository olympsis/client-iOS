//
//  ClubService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import Hermes
import SwiftUI
import Foundation

class ClubService {
    
    private var http: Courrier
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key, token: "Bearer " + tokenStore.FetchTokenFromKeyChain())
    }
    
    func getClubs(c: String, s: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/clubs", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .GET)
        return (data, resp)
    }
    
    func getClub(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/clubs/\(id)", queryItems: [URLQueryItem]())
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET)
        return data
    }
    
    // TODO: Add club to body need to create a club DAO
    func createClub(club: Club) async throws -> Data {
        let endpoint = Endpoint(path: "/clubs", queryItems: [URLQueryItem]())
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(club))
        return data
    }
    
    // TODO: FOR ADMINS
    
    func createClubApplication(id: String) async throws -> Bool {
        let endpoint = Endpoint(path: "/clubs/\(id)/applications", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .POST)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func deleteClubApplication(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/clubs/applications/\(id)", queryItems: [URLQueryItem]())
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: .DELETE)
        return data
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/clubs/\(id)/applications", queryItems: [URLQueryItem]())
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .GET)
        return (data, resp)
    }
    
    func updateApplication(app: ClubApplication) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(app.clubID)/applications/\(app.id)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(app))
        return resp
    }
    
    func changeRank(id: String, memberId: String, dao: ChangeRankDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(id)/members/\(memberId)/rank", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method:.PUT, body: EncodeToData(dao))
        return resp
    }
    
    func kickMember(id: String, memberId: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(id)/members/\(memberId)/kick", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT)
        return resp
    }
}

