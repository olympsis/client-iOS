//
//  UploadService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Hermes
import SwiftUI
import Foundation

class UploadService {
    
    private var http: Courrier
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key, token: tokenStore.FetchTokenFromKeyChain())
    }
    
    func GetUploadUrl(folder: String, object: String) async throws -> Data {
        
        let endpoint = Endpoint(path: "/v1/storage/\(folder)/\(object)", queryItems: [URLQueryItem]())
        
        let (data, _) = try await http.Request(endpoint: endpoint , method: .PUT)
        return data
    }
    
    func GetDeleteUrl(folder: String, object: String) async throws -> Data {
        
        let endpoint = Endpoint(path: "/v1/storage/\(folder)/\(object)", queryItems: [URLQueryItem]())
        
        let (data, _) = try await http.Request(endpoint: endpoint , method: .DELETE)
        return data
    }
    
    func UploadObject(url: String, body: Data) async throws -> URLResponse {
        
        //let (_, resp) = try await http.UploadImage(url: url, body: body)
        return URLResponse()
//        return resp
    }
}
