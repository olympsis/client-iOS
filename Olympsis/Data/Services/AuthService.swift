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
        log.log("Initiating request to server (PUT): /auth/signup")
        let data = try await http.request(url: "/V1/auth/signup", method: Method.PUT, param: req)
        return data
    }
    
    func LogIn(token: String) async throws -> Data{
        let req = AuthRequestLogin()
        req.token = token
        log.log("Initiating request to server(POST): /auth/login")
        let data = try await http.request(url: "/v1/auth/login", method: Method.POST, param: req)
        return data
    }
}

