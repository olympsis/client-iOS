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
    
    func Lookup(username: String) async throws -> UserPeek? {
        let (data,res) = try await userService.Lookup(username: username)
        guard (res as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        let object = try decoder.decode(UserPeek.self, from: data)
        return object
    }
    
    func GetFriendRequests() async throws -> [FriendRequest]? {
        let (data,res) = try await userService.GetFriendRequests()
        guard (res as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        let object = try decoder.decode(FriendRequests.self, from: data)
        return object.requests
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> Friend? {
        let (data,res) = try await userService.UpdateFriendRequest(id: id, dao: dao)
        guard (res as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        let object = try decoder.decode(Friend.self, from: data)
        return object
    }
    
    func CreateUserData(userName: String, sports:[String]) async throws -> UserDao? {
        let (data,res) = try await userService.CreateUserData(userName: userName, sports: sports)
        guard (res as? HTTPURLResponse)?.statusCode == 201 else {
            return nil
        }
        let object = try decoder.decode(UserDao.self, from: data)
        return object
    }
    
    func GetUserData() async throws -> UserDao {
        let response = try await userService.GetUserData()
        let object = try decoder.decode(UserDao.self, from: response)
        return object
    }
    
    // have this return a bool if status 200
    func UpdateUserData(update: UpdateUserDataDao) async -> Bool {
        do {
            let res = try await userService.UpdateUserData(update: update)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func getUserPrivateInfo() -> (String, String, String) {
        return cacheService.fetchIdentifiableData()
    }
    
    func fetchToken() {
        userService.http.fetchToken()
    }
}
