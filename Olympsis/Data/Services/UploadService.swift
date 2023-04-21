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
    
    func DeleteObject(url: String, name: String) async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/v1" + url)
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: [name: "X-FileName"])
        return (data, resp)
    }
    
    func UploadObject(url: String, fileType: String, fileName: String, body: Data) async throws {
        let endpoint = Endpoint(path: "/v1/storage" + url)
        if fileType == "image" {
            try await _uploadImage(endpoint: endpoint, name: fileName, data: body)
        } else {
            
        }
    }
    
    func _uploadImage(endpoint: Endpoint, name: String, data: Data) async throws {
        let type = ".jpeg"
        let contentType = "image/jpeg"
        try await self.http.Upload(endpoint: endpoint, fileName: name, fileType: type, contentType: contentType, data: data)
    }
}
