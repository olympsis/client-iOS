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
    private let tokenStore = SecureStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(scheme: "https", host: host, apiKey: key)
    }
    
    func SignUp(request: AuthRequest) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/auth/signup")
        return try await http.Request(endpoint: endpoint , method: .POST, body: EncodeToData(request))
    }
    
    func LogIn(request: AuthRequest) async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/auth/login")
        return try await http.Request(endpoint: endpoint, method: .POST, body: EncodeToData(request))
    }
    
    func DeleteAccount() async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/auth/delete")
        return try await http.Request(endpoint: endpoint, method: .DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func Token() async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/auth/token")
        return try await http.Request(endpoint: endpoint , method: .POST, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
}

