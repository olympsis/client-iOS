//
//  AuthObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import SwiftUI
import Foundation
import AuthenticationServices

class AuthObserver: ObservableObject {

    let log = Logger(subsystem: "com.josephlabs.olympsis", category: "auth_observer")
    let decoder =  JSONDecoder()
    let secureStore = SecureStore()
    let authService = AuthService()
    let cacheService = CacheService()
    
    @AppStorage("userID") var userID: String?
    
    func signUp(firstName:String, lastName:String, email:String, code: String) async throws {
        let req = AuthRequest(firstName: firstName, lastName: lastName, email: email, code: code, provider: "https://appleid.apple.com")
        let (data, _) = try await authService.SignUp(request: req)
        let object = try decoder.decode(AuthResponse.self, from: data)
        
        let usr = UserData(uuid: nil, username: nil, firstName: object.firstName, lastName: object.lastName, imageURL: nil, visibility: nil, bio: nil, clubs: nil, sports: nil, deviceToken: nil)
        
        // cache user data & token
        cacheService.cacheUser(user: usr)
        secureStore.saveTokenToKeyChain(token: object.token)
    }
    
    func refreshAuthToken() async {
        struct TokenResponse: Decodable {
            var authToken: String
        }
        
        do {
            let (data, _) = try await authService.Token()
            let object = try decoder.decode(TokenResponse.self, from: data)
            
            // cache token
            secureStore.saveTokenToKeyChain(token: object.authToken)
        } catch {
            log.error("failed to update token: \(error.localizedDescription)")
        }
    }
    
    func logIn(code: String) async throws {
        let req = AuthRequest(code: code, provider: "https://appleid.apple.com")
        let (data, _) = try await authService.LogIn(request: req)
        let object = try decoder.decode(AuthResponse.self, from: data)
        
        let usr = UserData(uuid: nil, username: nil, firstName: object.firstName, lastName: object.lastName, imageURL: nil, visibility: nil, bio: nil, clubs: nil, sports: nil, deviceToken: nil)
        
        // cache user data & token
        cacheService.cacheUser(user: usr)
        secureStore.saveTokenToKeyChain(token: object.token)
    }
    
    func deleteAccount() async throws -> Bool {
        // clear server data
        let (_, resp) = try await authService.DeleteAccount()
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            log.error("failed to delete remote user data")
            return false
        }
        return true
    }
    
    func handleSignInWithApple(result:  Result<ASAuthorization, Error>) async throws -> USER_STATUS {
        switch result {
        case .success(let authorization):
            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    /*
                        New User
                     */
                    
                    log.trace("new user signing in")
                    guard let code = appleIdCredential.authorizationCode,
                          let email = appleIdCredential.email,
                          let fullName = appleIdCredential.fullName,
                          let firstName = fullName.givenName,
                          let lastName = fullName.familyName else {
                        return USER_STATUS.unknown
                    }
                    secureStore.saveCurrentUserID(uuid: appleIdCredential.user)
                    try await signUp(firstName: firstName, lastName: lastName, email: email, code: String(data: code, encoding: .utf8)!)
                    return USER_STATUS.new
                } else {
                    /*
                        Existing User
                     */
                    
                    log.trace("existing user logging in")
                    guard let code = appleIdCredential.authorizationCode else {
                        return USER_STATUS.unknown
                    }
                    secureStore.saveCurrentUserID(uuid: appleIdCredential.user)
                    try await logIn(code: String(data: code, encoding: .utf8)!)
                    return USER_STATUS.returning
                }
            }
        case .failure(let error):
            log.error("apple signIn cancelled or an error occured: \(error)")
            throw error
        }
        return USER_STATUS.unknown
    }
    
    // check the status of the current user
    func checkAuthStatus(completion: @escaping (AUTH_STATUS) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        // fetch stored user id
        guard let userID = secureStore.fetchCurrentUserID() else {
            completion(AUTH_STATUS.unauthenticated)
            return
        }
        
        appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                let token = self.secureStore.fetchTokenFromKeyChain()
                if token != "" {
                    completion(AUTH_STATUS.authenticated)
                } else {
                    completion(AUTH_STATUS.unauthenticated)
                }
            case .revoked, .notFound:
                completion(AUTH_STATUS.unauthenticated)
            default:
                break
            }
        }
        completion(AUTH_STATUS.unknown)
    }
}

