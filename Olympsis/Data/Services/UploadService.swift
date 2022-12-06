//
//  UploadService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import SwiftUI
import Foundation

class UploadService: Service {
    
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    func GetUploadUrl(folder: String, object: String) async throws -> Data {
        
        let endpoint = Endpoint(path: "/v1/storage/\(folder)/\(object)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server (PUT): \(endpoint.path)")
        
        let (data, _) = try await http.Request(endpoint: endpoint , method: Method.PUT)
        return data
    }
    
    func GetDeleteUrl(folder: String, object: String) async throws -> Data {
        
        let endpoint = Endpoint(path: "/v1/storage/\(folder)/\(object)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server (DELETE): \(endpoint.path)")
        
        let (data, _) = try await http.Request(endpoint: endpoint , method: Method.DELETE)
        return data
    }
    
    func UploadObject(url: String, body: Data) async throws -> URLResponse {
        
        log.log("Initiating request to server (PUT): to Google Storage")
        
        let (_, resp) = try await http.UploadImage(url: url, body: body)
        return resp
    }
}
