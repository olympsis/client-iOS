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
    private let tokenStore = SecureStore()
    private let cacheService = CacheService()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key)
    }
    
    func getClubs(c: String, s: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/clubs", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return (data, resp)
    }
    
    func getClub(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/clubs/\(id)")
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return data
    }
    
    func createClub(club: Club) async throws -> Data {
        let endpoint = Endpoint(path: "/clubs")
        let (data, _) = try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(club), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return data
    }
    
    func leaveClub(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(id)/leave")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    // TODO: FOR ADMINS
    func deleteClub(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(id)")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
    
    func createClubApplication(id: String) async throws -> Bool {
        let endpoint = Endpoint(path: "/clubs/\(id)/applications")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .POST, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func deleteClubApplication(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/clubs/applications/\(id)")
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return data
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/clubs/\(id)/applications")
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .GET, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return (data, resp)
    }
    
    func updateApplication(id: String, appID: String, req: ApplicationUpdateRequest) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(id)/applications/\(appID)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(req), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
    
    func changeRank(id: String, memberId: String, role: String) async throws -> URLResponse {
        let req = ChangeRoleRequest(role: role)
        let endpoint = Endpoint(path: "/clubs/\(id)/members/\(memberId)/rank")
        let (_, resp) = try await http.Request(endpoint: endpoint, method:.PUT, body: EncodeToData(req), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
    
    func kickMember(id: String, memberId: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/clubs/\(id)/members/\(memberId)/kick")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
}

