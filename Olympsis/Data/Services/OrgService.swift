//
//  OrgService.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import os
import Hermes
import SwiftUI
import Foundation

class OrgService {
    
    private var http: Courrier
    private let tokenStore = SecureStore()
    private let cacheService = CacheService()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key)
    }
    
    func getOrganizations(c: String, s: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/organizations", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .GET, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return (data, resp)
    }
    
    func getOrganization(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/organizations/\(id)")
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return data
    }
    
    func createOrganization(org: Organization) async throws -> Data {
        let endpoint = Endpoint(path: "/organizations")
        let (data, _) = try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(org), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return data
    }
    
    // TODO: FOR ADMINS
    func deleteOrganization(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/organizations/\(id)")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return resp
    }
    
    // APPLICATIONS
    
    func createApplication(app: OrganizationApplication) async throws -> Bool {
        let endpoint = Endpoint(path: "/organizations/applications")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(app), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/organizations/\(id)/applications")
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .GET, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return (data, resp)
    }
    
    func updateApplication(id: String, app: OrganizationApplication) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/organizations/applications/\(id)")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(app), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return resp
    }
    
    func deleteApplication(id: String) async throws -> Data {
        let endpoint = Endpoint(path: "/organizations/applications/\(id)")
        let (data, _) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return data
    }
    
    // INVITATIONS
    
    func createInvitation(data: Invitation) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/organizations/invitations")
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(data), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
    }
    
    func updateInvitation(data: Invitation) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/organizations/invitations/\(data.id ?? "")")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(data), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return resp
    }
    
    func pinPost(id: String, postId: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/organizations/\(id)/post/\(postId)")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
    
    func unPinPost(id: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/organizations/\(id)/post")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain(),
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
}


