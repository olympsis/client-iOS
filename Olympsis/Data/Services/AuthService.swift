//
//  AuthService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import Hermes
import Foundation
import FirebaseAuth

class AuthService {
    
    private var http: Courrier
    
    init() {
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func Register(request: AuthRequest) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/v1/auth/register")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func LogIn(request: AuthRequest) async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/v1/auth/login")
        return try await http.Request(.POST, endpoint, body: EncodeToData(request))
    }
    
    func DeleteAccount() async throws -> (Data, URLResponse){
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/auth/delete")
        return try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
    }
}

