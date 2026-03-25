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

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }
    
    func UserNameAvailability(name: String) async throws -> Data {
        let endpoint = Endpoint("/v1/users/username", queryItems: [URLQueryItem(name: "username", value: name)])
        let (data, _) = try await http.Request(.GET, endpoint)
        return data
    }
    
    func GetFriendRequests() async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/friends/requests", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(.GET, endpoint, headers: headers)
        return (data, res)
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/friends/requests/\(id)", queryItems: [URLQueryItem]())
        let (data, res) = try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: headers)
        return (data, res)
    }
    
    func createUserData(userName: String, sports:[String]) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let req = UserDao(username: userName, sports: sports, visibility: "public", hasOnboarded: false)
        let endpoint = Endpoint("/v1/users", queryItems: [URLQueryItem]())
        return try await http.Request(.POST, endpoint, body: EncodeToData(req), headers: headers)
    }
    
    func GetUserData() async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/user", queryItems: [URLQueryItem]())
        return try await http.Request(.GET, endpoint, headers: headers)
    }
    
    func UpdateUserData(update: UserDao) async throws -> (Data,URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/user", queryItems: [URLQueryItem]())
        return try await http.Request(.PUT, endpoint, body: EncodeToData(update), headers: headers)
    }
    
    func SearchUsersByUsername(username: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/search/username", queryItems: [
            URLQueryItem(name: "username", value: username)
        ])
        return try await http.Request(.GET, endpoint, headers: headers)
    }
    
    func getUserByUUID(uuid: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/search/uuid", queryItems: [
            URLQueryItem(name: "uuid", value: uuid)
        ])
        return try await http.Request(.GET, endpoint, headers: headers)
    }
    
    func GetOrganizationInvitations() async throws -> (Data, URLResponse){
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/invitations/organizations")
        return try await http.Request(.GET, endpoint, headers: headers)
    }
    
    func CheckIn() async throws -> (Data, URLResponse){
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/users/check-in")
        return try await http.Request(.GET, endpoint, headers: headers)
    }
}
