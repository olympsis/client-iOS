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
import FirebaseAuth

class OrgService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    private let cacheService: CacheService
    
    init() {
        self.tokenStore = SecureStore()
        self.cacheService = CacheService()
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func getOrganizations(c: String, s: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        let (data, resp) = try await http.Request(.GET, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return (data, resp)
    }
    
    func getOrganization(id: String) async throws -> Data {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return data
    }
    
    func createOrganization(org: OrganizationDao) async throws -> Data {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations")
        let (data, _) = try await http.Request(.POST, endpoint, body: EncodeToData(org), headers: [
            "Authorization": token ?? ""
        ])
        return data
    }
    
    // TODO: FOR ADMINS
    func deleteOrganization(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/\(id)")
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    // APPLICATIONS
    
    func createApplication(app: OrganizationApplication) async throws -> Bool {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/applications")
        
        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(app), headers: [
            "Authorization": token ?? ""
        ])
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/\(id)/applications")
        let (data, resp) = try await http.Request(.GET, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return (data, resp)
    }
    
    func updateApplication(id: String, app: OrganizationApplication) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/applications/\(id)")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(app), headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func deleteApplication(id: String) async throws -> Data {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/applications/\(id)")
        let (data, _) = try await http.Request(.DELETE, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return data
    }
    
    // INVITATIONS
    
    func createInvitation(data: Invitation) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/invitations")
        return try await http.Request(.POST, endpoint, body: EncodeToData(data), headers: [
            "Authorization": token ?? ""
        ])
    }
    
    func updateInvitation(data: Invitation) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/invitations/\(data.id ?? "")")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(data), headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func pinPost(id: String, postId: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/\(id)/post/\(postId)")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: [
            "Authorization": token ?? "",
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
    
    func unPinPost(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/organizations/\(id)/post")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: [
            "Authorization": token ?? "",
            "X-Admin-Token": cacheService.fetchClubAdminToken(id: id)
        ])
        return resp
    }
}


