//
//  AuthObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import SwiftUI
import Dispatch
import Foundation
import AuthenticationServices

class AuthObserver: ObservableObject {
    
    var log = Logger()
    
    @AppStorage("firstName")    var firstName: String? // user email
    @AppStorage("lastName")     var lastName: String? // user last name
    @AppStorage("email")        var email:String?  // user email
    @AppStorage("token")        var token:String? // auth token from server
    @AppStorage("userId")       var userId: String? // user id from apple servers
    
    let authService = AuthService()
    //let userService = UserService()
    
    func SignUp(firstName:String, lastName:String, email:String, token: String) async throws -> String {
        let response = try await authService.SignUp(firstName: firstName, lastName: lastName, email: email, token: token)
        let decoder = JSONDecoder()
        let object = try decoder.decode(AuthResponseDao.self, from: response)
        return object.token
    }
    
    func LogIn(token: String) async throws -> String {
        let response = try await authService.LogIn(token: token)
        let decoder = JSONDecoder()
        let object = try decoder.decode(AuthResponseDao.self, from: response)
        return object.token
    }
    
    func handleSignInWithApple(result:  Result<ASAuthorization, Error>) async throws -> USER_STATUS{
        switch result {
        case .success(let authorization):
            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    /*
                        New User
                     */
                    log.log("New User")
                    let _userId = appleIdCredential.user
                    let _token = String(data: appleIdCredential.identityToken!, encoding: .utf8)!
                    let _ = appleIdCredential.authorizationCode
                    let _email = appleIdCredential.email!
                    let _firstName = (appleIdCredential.fullName?.givenName!)!
                    let _lastName = (appleIdCredential.fullName?.familyName!)!
                    let _ = appleIdCredential.state
                    
                    await MainActor.run{
                        firstName = _firstName
                        lastName = _lastName
                        email = _email
                        userId = _userId
                    }
                    Task {
                        let res = try await SignUp(firstName: _firstName, lastName: _lastName, email: _email, token: _token)
                        DispatchQueue.main.async {
                            self.token = res
                        }
                    }
                    return USER_STATUS.New
                } else {
                    /*
                        Existing User
                     */
                    log.log("Returning User")
                    let _token = String(data: appleIdCredential.identityToken!, encoding: .utf8)!
                    Task {
                        let res = try await LogIn(token: _token)
                        DispatchQueue.main.async {
                            self.token = res
                        }
                    }
                    return USER_STATUS.Returning
                }
            }
        case .failure(let error):
            throw error
        }
        return USER_STATUS.Unknown
    }
}

