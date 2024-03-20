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
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host)
    }
    
    func UploadObject(url: String, fileType: String, fileName: String, body: Data) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/storage" + url)
        
        let (data, resp) = try await _uploadImage(endpoint: endpoint, name: fileName, data: body)
        return (data, resp)
    }
    
    func DeleteObject(url: String, fileName: String) async throws -> (Data, URLResponse){
        let endpoint = Endpoint("/storage" + url)
        
        let (data, resp) = try await http.Request(.DELETE, endpoint, headers: ["X-Filename" : fileName, "Authorization":tokenStore.fetchTokenFromKeyChain()])
        return (data, resp)
    }
    
    func _uploadImage(endpoint: Endpoint, name: String, data: Data) async throws -> (Data, URLResponse) {
        let type = ".jpeg"
        let (data, response) = try await self.http.Upload(endpoint: endpoint, fileName: name, fileType: .JPEG, data: data, headers: ["X-Filename" : name+type, "Authorization":tokenStore.fetchTokenFromKeyChain()])
        return (data, response)
    }
}
