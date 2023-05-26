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
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(scheme: "https", host: host, apiKey: key, token: tokenStore.FetchTokenFromKeyChain())
    }
    
    func UserNameAvailability(name: String) async throws -> Data {
        let endpoint = Endpoint(path: "/users/username", queryItems: [URLQueryItem(name: "username", value: name)])
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET)
        return data
    }
    
    func Lookup(username: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/lookup/username/\(username)", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(endpoint: endpoint, method: .GET)
        return (data, res)
    }
    
    func GetFriendRequests() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/users/friends/requests", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(endpoint: endpoint, method: .GET)
        return (data, res)
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/users/friends/requests/\(id)", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(dao))
        return (data, res)
    }
    
    func CreateUserData(userName: String, sports:[String]) async throws -> (Data, URLResponse) {
        let req = User(username: userName, visibility: "public", sports: sports)
        let endpoint = Endpoint(path: "/users", queryItems: [URLQueryItem]())
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(req))
    }
    
    func GetUserData() async throws -> Data {
        let endpoint = Endpoint(path: "/users", queryItems: [URLQueryItem]())
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET)
        return data
    }
    
    func UpdateUserData(update: UpdateUserDataDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/users", queryItems: [URLQueryItem]())
        let (_, resp) = try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(update))
        return resp
    }
}
