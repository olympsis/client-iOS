//
//  UserObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//
import os
import Foundation

class UserObserver: ObservableObject {
    
    private let decoder = JSONDecoder()
    private let userService = UserService()
    
    func CheckUserName(name: String) async throws -> Bool {
        let response = try await userService.UserNameAvailability(name: name)
        let object = try decoder.decode(UsernameAvailabilityResponse.self, from: response)
        return object.isAvailable
    }
    
    func GetFriendRequests() async throws -> [FriendRequest]? {
        let (data,_) = try await userService.GetFriendRequests()
        let object = try decoder.decode(FriendRequests.self, from: data)
        return object.requests
    }
    
    func UpdateFriendRequest(id: String, dao: UpdateFriendRequestDao) async throws -> Friend? {
        let (data,_) = try await userService.UpdateFriendRequest(id: id, dao: dao)
        let object = try decoder.decode(Friend.self, from: data)
        return object
    }
    
    func createUserData(username: String, sports:[String]) async throws -> User? {
        let (data,_) = try await userService.createUserData(userName: username, sports: sports)
        let object = try decoder.decode(User.self, from: data)
        return object
    }
    
    func GetUserData() async throws -> User {
        let response = try await userService.GetUserData()
        let object = try decoder.decode(User.self, from: response)
        return object
    }
    
    // have this return a bool if status 200
    func UpdateUserData(update: User) async -> Bool {
        do {
            _ = try await userService.UpdateUserData(update: update)
            return true
        } catch {
            print(error)
        }
        return false
    }
}
