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

class UserService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(scheme: "https", host: host, apiKey: key)
    }
    
    func UserNameAvailability(name: String) async throws -> Data {
        let endpoint = Endpoint(path: "/users/username", queryItems: [URLQueryItem(name: "username", value: name)])
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET)
        return data
    }
    
    func GetFriendRequests() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/users/friends/requests", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return (data, res)
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/users/friends/requests/\(id)", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return (data, res)
    }
    
    func createUserData(userName: String, sports:[String]) async throws -> (Data, URLResponse) {
        let req = User(username: userName, visibility: "public", sports: sports)
        let endpoint = Endpoint(path: "/users", queryItems: [URLQueryItem]())
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(req), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func GetUserData() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/users/user", queryItems: [URLQueryItem]())
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func UpdateUserData(update: User) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/users/user", queryItems: [URLQueryItem]())
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(update), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func SearchUsersByUsername(username: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/users/search/username", queryItems: [
            URLQueryItem(name: "username", value: username)
        ])
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func GetOrganizationInvitations() async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/users/invitations/organizations")
        return try await http.Request(endpoint: endpoint, method: .GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
}
