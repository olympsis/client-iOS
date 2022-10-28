//
//  UserObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//
import os
import Foundation

class UserObserver: ObservableObject {
    private let decoder: JSONDecoder
    private let userService: UserService
    private let cacheService: CacheService
    
    init() {
        decoder = JSONDecoder()
        userService = UserService()
        cacheService = CacheService()
    }
    
    func CheckUserName(name: String) async throws -> Bool {
        let response = try await userService.CheckUserName(name: name)
        let object = try decoder.decode(UserNameResponse.self, from: response)
        return object.isFound
    }
    
    func CreateUserData(userName: String, sports:[String]) async throws -> Bool {
        let response = try await userService.CreateUserData(userName: userName, sports: sports)
        return response
    }
    
    func GetUserData() async throws -> UserDataResponse {
        let response = try await userService.GetUserData()
        let object = try decoder.decode(UserDataResponse.self, from: response)
        return object
    }
    
    func getUserPrivateInfo() -> (String, String, String, String) {
        return cacheService.fetchPartialUserData()
    }
    
    func fetchToken() {
        userService.http.fetchToken()
    }
}
