//
//  UserObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import Foundation

class UserObserver: ObservableObject {
    let userService = UserService()
    func CheckUserName(name: String) async throws -> Bool {
        let response = try await userService.CheckUserName(name: name)
        let decoder = JSONDecoder()
        let object = try decoder.decode(UserNameResponse.self, from: response)
        return object.isFound
    }
}
