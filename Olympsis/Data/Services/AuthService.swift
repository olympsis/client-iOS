//
//  AuthService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import Hermes
import SwiftUI
import Foundation

class AuthService {
    
    private var http: Courrier
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key)
    }
    
    func SignUp(request: SignInRequest) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/auth/signup", queryItems: [URLQueryItem]())
        return try await http.Request(endpoint: endpoint , method: .POST, body: EncodeToData(request))
    }
    
    func LogIn(request: LoginRequest) async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/v1/auth/login", queryItems: [URLQueryItem]())
        return try await http.Request(endpoint: endpoint, method: .PUT, body: EncodeToData(request))
    }
    
    func DeleteAccount() async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/v1/auth/delete", queryItems: [URLQueryItem]())
        return try await http.Request(endpoint: endpoint, method: .DELETE)
    }
}

