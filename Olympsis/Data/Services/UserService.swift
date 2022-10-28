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
        let req = UserNameRequest(name: name)
        req.userName = name
        log.log("Initiating request to server(GET): /user/userName")
        let (data, _) = try await http.request(url: "/v1/user/userName?userName=\(req.userName)", method: Method.GET, body: req)
        return data
    }
    
    func CreateUserData(userName: String, sports:[String]) async throws -> Bool {
        let req = CreateUserDataRequest(userName: userName, sports: sports)
        log.log("Initiating request to server(PUT): /user/userData")
        let (_, resp) = try await http.request(url: "/v1/user/userData", method: Method.PUT, body: req)
        return (resp as? HTTPURLResponse)?.statusCode == 201 ? true : false
    }
    
    func GetUserData() async throws -> Data {
        log.log("Initiating request to server(GET): /user/userData")
        let (data, _) = try await http.request(url: "/v1/user/userData", method: Method.GET)
        return data
    }
}
