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

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }
    
    func register(request: AuthRequest) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/v1/auth/register")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func login(request: AuthRequest) async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/v1/auth/login")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func modify(request: AuthUserDao) async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/v1/auth/modify")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func deleteAccount() async throws -> (Data, URLResponse){
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/auth/delete")
        return try await http.Request(.DELETE, endpoint, headers: headers)
    }
}

