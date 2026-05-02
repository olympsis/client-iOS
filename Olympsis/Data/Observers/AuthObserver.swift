//
//  AuthObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import SwiftUI
import CryptoKit
import Foundation
import FirebaseAuth
import AuthenticationServices

@MainActor
class AuthObserver: ObservableObject {

    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    let secureStore = SecureStore()
    let authService = AuthService()
    let cacheService = CacheService()
    let log = Logger(subsystem: "com.olympsis.client", category: "auth_observer")
    
    @AppStorage("auth_type") private var authType: USER_STATUS?
    
    func register(firstName:String, lastName:String, email:String, token: String) async throws {
        let req = AuthRequest(firstName: firstName, lastName: lastName, email: email, token: token)
        let (_, resp) = try await authService.register(request: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200  else {
            return
        }
    }
    
    func login(token: String) async throws -> USER_STATUS {
        let req = AuthRequest(token: token)
        let (data, resp) = try await authService.login(request: req)

        if let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 404 {
            return .not_finished
        }

        let object = try decoder.decode(User.self, from: data)

        // store user data
        cacheService.cacheUser(user: object)
        return .returning
    }
    
    func updateUser(_ dao: AuthUserDao) async throws -> Bool {
        let (_, resp) = try await authService.modify(request: dao)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }
        
        return true
    }
    
    func deleteAccount() async throws -> Bool {
        // clear server data
        let (_, resp) = try await authService.deleteAccount()
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            log.error("Failed to delete remote user data")
            return false
        }
        return true
    }

    
    func handleSignInWithApple(result:  Result<ASAuthorization, Error>, nonce: String?) async throws -> USER_STATUS {
        
        switch result {
        case .success(let authorization):
            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = nonce else {
                    log.error("Invalid state: A login callback was received, but no login request was sent.")
                    return .unknown
                }

                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    
                    /*
                        New User
                     */
                    self.authType = .new
                    log.debug("New user signing in")
                    guard let idToken = appleIdCredential.identityToken
                              .flatMap({ String(data: $0, encoding: .utf8) }) else {
                        return USER_STATUS.unknown
                    }
                    
                    // Name/email may be nil if Apple doesn't return them
                    let email = appleIdCredential.email ?? ""
                    let firstName = appleIdCredential.fullName?.givenName ?? ""
                    let lastName = appleIdCredential.fullName?.familyName ?? ""
                    
                    let creds = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: appleIdCredential.fullName)
                    
                    do {
                        try await Auth.auth().signIn(with: creds)
                        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
                            return USER_STATUS.unknown
                        }
                        
                        try await register(firstName: firstName, lastName: lastName, email: email, token: token)
                        
                        return USER_STATUS.new
                    } catch {
                        log.error("Authentication Failed: \(error.localizedDescription)")
                        return USER_STATUS.unknown
                    }
                    
                } else {
                    
                    /*
                        Existing User
                     */
                    self.authType = .returning
                    log.debug("Existing user logging in")
                    guard let idToken = appleIdCredential.identityToken
                              .flatMap({ String(data: $0, encoding: .utf8) }) else {
                        return USER_STATUS.unknown
                    }
                    
                    let creds = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
                    
                    do {
                        try await Auth.auth().signIn(with: creds)
                        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
                            return USER_STATUS.unknown
                        }
                        
                        let status = try await login(token: token)

                        // user not found on server
                        if status == .not_finished {
                            return USER_STATUS.not_finished
                        }

                        let user = cacheService.fetchUser()
                        guard user?.firstName != "",
                            user?.username != "",
                              user?.sports != nil,
                              user?.visibility != "" else {
                            return USER_STATUS.not_finished
                        }

                        return USER_STATUS.returning
                    } catch {
                        log.error("Authentication Failed: \(error.localizedDescription)")
                        return USER_STATUS.unknown
                    }
                }
            }
        case .failure(let error):
            log.error("SignIn with Apple was cancelled or an error occured: \(error)")
            throw error
        }
        return USER_STATUS.unknown
    }
}

