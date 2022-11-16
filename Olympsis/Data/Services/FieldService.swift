//
//  FieldService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import SwiftUI
import Foundation

class FieldService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    func getFields() async throws -> Data {
        let endpoint = Endpoint(path: "/v1/fields", queryItems: [
            URLQueryItem(name: "country", value: "United States of America"),
            URLQueryItem(name: "state", value: "Utah")
        ])
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        let (data, _) = try await http.request(endpoint: endpoint, method: Method.GET)
        return data
    }
}
