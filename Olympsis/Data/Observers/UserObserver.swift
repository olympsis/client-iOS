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
    
    enum UserObserverError: Error {
        case NotFound
        case Unknown
    }
    
    init() {
        decoder = JSONDecoder()
        userService = UserService()
    }
    
    func UsernameAvailability(name: String) async throws -> Bool {
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
        let (data, resp) = try await userService.GetUserData()
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw UserObserverError.NotFound
        }
        let object = try decoder.decode(User.self, from: data)
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
    
    func SearchUsersByUsername(username: String) async throws -> [UserData] {
        let (data, resp) = try await userService.SearchUsersByUsername(username: username)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return [UserData]()
        }
        let object = try decoder.decode(UsersDataResponse.self, from: data)
        return object.users
    }
    
    func GetOrganizationInvitations() async throws -> [Invitation] {
        let (data, resp) = try await userService.GetOrganizationInvitations()
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return [Invitation]()
        }
        let object = try decoder.decode(InvitationsResponse.self, from: data)
        return object.invitations
    }
}
