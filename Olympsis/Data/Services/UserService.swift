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
        self.tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host, sessionConfig: .default)
    }
    
    func UserNameAvailability(name: String) async throws -> Data {
        let endpoint = Endpoint("/users/username", queryItems: [URLQueryItem(name: "username", value: name)])
        let (data, _) = try await http.Request(.GET, endpoint)
        return data
    }
    
    func GetFriendRequests() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/users/friends/requests", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return (data, res)
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/users/friends/requests/\(id)", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return (data, res)
    }
    
    func createUserData(userName: String, sports:[String]) async throws -> (Data, URLResponse) {
        let req = User(username: userName, visibility: "public", sports: sports)
        let endpoint = Endpoint("/users", queryItems: [URLQueryItem]())
        return try await http.Request(.POST, endpoint, body: EncodeToData(req), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func GetUserData() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/users/user", queryItems: [URLQueryItem]())
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func UpdateUserData(update: UserDao) async throws -> URLResponse {
        let endpoint = Endpoint("/users/user", queryItems: [URLQueryItem]())
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(update), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func SearchUsersByUsername(username: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/users/search/username", queryItems: [
            URLQueryItem(name: "username", value: username)
        ])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func GetOrganizationInvitations() async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/users/invitations/organizations")
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func CheckIn() async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/users/check-in")
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
}
