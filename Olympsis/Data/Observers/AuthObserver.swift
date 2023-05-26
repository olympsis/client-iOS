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
    let tokenStore = TokenStore()
    
    init() {
        decoder = JSONDecoder()
        authService = AuthService()
        cacheService = CacheService()
    }
    
    func SignUp(firstName:String, lastName:String, email:String, code: String) async throws {
        let req = AuthRequest(firstName: firstName, lastName: lastName, email: email, code: code, provider: "https://appleid.apple.com")
        let (data, _) = try await authService.SignUp(request: req)
        
        let object = try decoder.decode(AuthResponse.self, from: data)
        await cacheService.cacheToken(token: object.token)
        
        _ = await MainActor.run {
            tokenStore.SaveTokenToKeyChain(token: object.token)
        }
    }
    
    func LogIn(code: String) async throws {
        let req = AuthRequest(code: code, provider: "https://appleid.apple.com")
        
        let (data, _) = try await authService.LogIn(request: req)

        let object = try decoder.decode(AuthResponse.self, from: data)
        await cacheService.chacheIdentifiableData(firstName: object.firstName!, lastName: object.lastName!, email: object.email!)
        await cacheService.cacheToken(token: object.token)
        
        _ = await MainActor.run(body: {
            tokenStore.SaveTokenToKeyChain(token: object.token)
        })
    }
    
    func DeleteAccount() async throws -> Bool {
        let (_, resp) = try await authService.DeleteAccount()
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }
        return true
    }
    
    func HandleSignInWithApple(result:  Result<ASAuthorization, Error>) async throws -> USER_STATUS{
        switch result {
        case .success(let authorization):
            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    /*
                        New User
                     */
                    let code = appleIdCredential.authorizationCode!
                    let email = appleIdCredential.email!
                    let firstName = (appleIdCredential.fullName?.givenName!)!
                    let lastName = (appleIdCredential.fullName?.familyName!)!
                    await cacheService.chacheIdentifiableData(firstName: firstName, lastName: lastName, email: email)
                    try await SignUp(firstName: firstName, lastName: lastName, email: email, code: String(data: code, encoding: .utf8)!)
                    return USER_STATUS.New
                } else {
                    /*
                        Existing User
                     */
                    let code = appleIdCredential.authorizationCode!
                    try await LogIn(code: String(data: code, encoding: .utf8)!)
                    return USER_STATUS.Returning
                }
            }
        case .failure(let error):
            throw error
        }
        return USER_STATUS.Unknown
    }
}

