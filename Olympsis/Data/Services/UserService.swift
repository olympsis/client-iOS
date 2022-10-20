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
        log.log("Initiating request to server(POST): /user/userName")
        let data = try await http.request(url: "/v1/user/userName?userName=\(req.userName)", method: Method.GET, param: req)
        return data
    }
}
