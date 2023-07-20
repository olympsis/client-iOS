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
    private let tokenStore = SecureStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key)
    }
    
    func UploadObject(url: String, fileType: String, fileName: String, body: Data) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/storage" + url)
        
        let (data, resp) = try await _uploadImage(endpoint: endpoint, name: fileName, data: body)
        return (data, resp)
    }
    
    func DeleteObject(url: String, fileName: String) async throws -> (Data, URLResponse){
        let endpoint = Endpoint(path: "/v1/storage" + url)
        
        let (data, resp) = try await http.Request(endpoint: endpoint, method: .DELETE, headers: ["X-Filename" : fileName, "Authorization":tokenStore.fetchTokenFromKeyChain()])
        return (data, resp)
    }
    
    func _uploadImage(endpoint: Endpoint, name: String, data: Data) async throws -> (Data, URLResponse) {
        let type = ".jpeg"
        let contentType = "image/jpeg"
        let (data, response) = try await self.http.Upload(endpoint: endpoint, fileName: name, fileType: type, contentType: contentType, data: data)
        return (data, response)
    }
}
