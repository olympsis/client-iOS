//
//  AuthService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import Hermes
import Foundation

class AuthService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host)
    }
    
    func SignUp(request: AuthRequest) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/auth/signup")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func LogIn(request: AuthRequest) async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/auth/login")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func DeleteAccount() async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/auth/delete")
        return try await http.Request(.DELETE, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func Token() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/auth/token")
        return try await http.Request(.POST, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
}

