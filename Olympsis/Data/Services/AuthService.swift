//
//  AuthService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import os
import SwiftUI
import Foundation

class AuthService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    func SignUp(firstName:String, lastName:String, email:String, token:String) async throws -> Data{
        let req = AuthRequestSignIn()
        req.firstName   = firstName
        req.lastName    = lastName
        req.email       = email
        req.token       = token
        
        let endpoint = Endpoint(path: "/v1/auth/signup", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server (POST): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint , method: Method.POST, body: req)
        return data
    }
    
    func LogIn(token: String) async throws -> Data{
        let req = AuthRequestLogin()
        req.token = token
        
        let endpoint = Endpoint(path: "/v1/auth/login", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.PUT, body: req)
        return data
    }
}

