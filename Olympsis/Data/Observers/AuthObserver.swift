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

    let decoder: JSONDecoder
    let authService: AuthService
    let cacheService: CacheService
    
    init() {
        decoder = JSONDecoder()
        authService = AuthService()
        cacheService = CacheService()
    }
    
    func SignUp(firstName:String, lastName:String, email:String, token: String) async throws {
        let response = try await authService.SignUp(firstName: firstName, lastName: lastName, email: email, token: token)
        let object = try decoder.decode(AuthResponseDao.self, from: response)
        await cacheService.cacheToken(token: object.token)
    }
    
    func LogIn(token: String) async throws {
        let response = try await authService.LogIn(token: token)
        let object = try decoder.decode(AuthResponseDao.self, from: response)
        await cacheService.cacheToken(token: object.token)
    }
    
    func handleSignInWithApple(result:  Result<ASAuthorization, Error>) async throws -> USER_STATUS{
        switch result {
        case .success(let authorization):
            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    /*
                        New User
                     */
                    let userId = appleIdCredential.user
                    let token = String(data: appleIdCredential.identityToken!, encoding: .utf8)!
                    let _ = appleIdCredential.authorizationCode
                    let email = appleIdCredential.email!
                    let firstName = (appleIdCredential.fullName?.givenName!)!
                    let lastName = (appleIdCredential.fullName?.familyName!)!
                    let _ = appleIdCredential.state
                    
                    // store private user info on device
                    await cacheService.cachePartialUserData(firstName: firstName, lastName: lastName, email: email, uuid: userId)
                    
                    // Network request to create auth user in database
                    try await SignUp(firstName: firstName, lastName: lastName, email: email, token: token)
                    
                    return USER_STATUS.New
                } else {
                    /*
                        Existing User
                     */
                    let _token = String(data: appleIdCredential.identityToken!, encoding: .utf8)!
                    
                    // Network request to login user into backend
                    try await LogIn(token: _token)
                    
                    return USER_STATUS.Returning
                }
            }
        case .failure(let error):
            throw error
        }
        return USER_STATUS.Unknown
    }
}

