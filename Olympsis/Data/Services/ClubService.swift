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
import FirebaseAuth

class ClubService {
    
    private var http: Courrier
    
    init() {
        #if targetEnvironment(simulator)
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func getClubs(c: String, s: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        let (data, resp) = try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
        return (data, resp)
    }
    
    func getUserClubs(clubs: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/user", queryItems: [
            URLQueryItem(name: "clubs", value: clubs)
        ])
        let (data, resp) = try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
        return (data, resp)
    }
    
    func getClub(id: String) async throws -> Data {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
        return data
    }
    
    func createClub(club: ClubDao) async throws -> Data {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs")
        let (data, _) = try await http.Request(.POST, endpoint, body: EncodeToData(club), headers: ["Authorization": token ?? ""])
        return data
    }
    
    func updateClub(id: String, club: ClubDao) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(club), headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func leaveClub(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/leave")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: ["Authorization": token ?? ""])
        return resp
    }
    
    // TODO: FOR ADMINS
    func deleteClub(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)")
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func createClubApplication(id: String) async throws -> Bool {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/applications")
        
        let (_, resp) = try await http.Request(.POST, endpoint, headers: ["Authorization": token ?? ""])
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func deleteClubApplication(id: String) async throws -> Data {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/applications/\(id)")
        
        let (data, _) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
        return data
    }
    
    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/applications")
        
        let (data, resp) = try await http.Request(.GET, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return (data, resp)
    }
    
    func updateApplication(id: String, appID: String, req: ApplicationUpdateRequest) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/applications/\(appID)")
        
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(req), headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func changeRank(id: String, memberId: String, role: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let req = ChangeRoleRequest(role: role)
        let endpoint = Endpoint("/v1/clubs/\(id)/members/\(memberId)/rank")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(req), headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func kickMember(id: String, memberId: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/members/\(memberId)/kick")
        
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func pinPost(id: String, postId: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/post/\(postId)")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
    
    func unPinPost(id: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/clubs/\(id)/post")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: [
            "Authorization": token ?? ""
        ])
        return resp
    }
}

