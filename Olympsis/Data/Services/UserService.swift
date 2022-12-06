//
//  UserService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/22.
//

import os
import SwiftUI
import Foundation

class UserService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    
    func CheckUserName(name: String) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/users", queryItems: [URLQueryItem(name: "userName", value: name)])
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        let (data, _) = try await http.Request(endpoint: endpoint, method: Method.GET)
        return data
    }
    
    func CreateUserData(userName: String, sports:[String]) async throws -> Bool {
        let req = CreateUserDataRequest(userName: userName, sports: sports)
        let endpoint = Endpoint(path: "/v1/users", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.POST, body: req)
        return (resp as? HTTPURLResponse)?.statusCode == 201 ? true : false
    }
    
    func GetUserData() async throws -> Data {
        let endpoint = Endpoint(path: "/v1/users/user", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        let (data, _) = try await http.Request(endpoint: endpoint, method: Method.GET)
        return data
    }
    
    func UpdateUserData(update: UpdateUserDataDao) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/users/user", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(PUT): \(endpoint.path)")
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.PUT, body: update)
        return resp
    }
}
