//
//  UserService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import os
import Hermes
import SwiftUI
import Foundation
import FirebaseAuth

class UserService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func UserNameAvailability(name: String) async throws -> Data {
        let endpoint = Endpoint("/v1/users/username", queryItems: [URLQueryItem(name: "username", value: name)])
        let (data, _) = try await http.Request(.GET, endpoint)
        return data
    }
    
    func GetFriendRequests() async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/friends/requests", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
        return (data, res)
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/friends/requests/\(id)", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": token ?? ""])
        return (data, res)
    }
    
    func createUserData(userName: String, sports:[String]) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let req = User(username: userName, visibility: "public", sports: sports)
        let endpoint = Endpoint("/v1/users", queryItems: [URLQueryItem]())
        return try await http.Request(.POST, endpoint, body: EncodeToData(req), headers: ["Authorization": token ?? ""])
    }
    
    func GetUserData() async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/user", queryItems: [URLQueryItem]())
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func UpdateUserData(update: UserDao) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/user", queryItems: [URLQueryItem]())
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(update), headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func SearchUsersByUsername(username: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/search/username", queryItems: [
            URLQueryItem(name: "username", value: username)
        ])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func GetOrganizationInvitations() async throws -> (Data, URLResponse){
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/invitations/organizations")
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func CheckIn() async throws -> (Data, URLResponse){
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/users/check-in")
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
}
