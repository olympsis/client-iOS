//
//  UploadService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Hermes
import SwiftUI
import Foundation
import FirebaseAuth

class UploadService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        #if DEBUG
            // Eventually we want to have a local way of testing the upload server
            let host = Bundle.main.object(forInfoDictionaryKey: "STORAGE") as? String ?? ""
            self.http = Courrier(.HTTP, host: host)
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "STORAGE") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func UploadObject(url: String, fileType: String, fileName: String, body: Data) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/v1/storage" + url)
        
        let (data, resp) = try await _uploadImage(endpoint: endpoint, name: fileName, data: body)
        return (data, resp)
    }
    
    func DeleteObject(url: String, fileName: String) async throws -> (Data, URLResponse){
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/storage" + url)
        
        let (data, resp) = try await http.Request(.DELETE, endpoint, headers: ["X-Filename" : fileName, "Authorization": token ?? ""])
        return (data, resp)
    }
    
    func _uploadImage(endpoint: Endpoint, name: String, data: Data) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let type = ".jpeg"
        let (data, response) = try await self.http.Upload(endpoint: endpoint, fileName: name, fileType: .JPEG, data: data, headers: ["X-Filename" : name+type, "Authorization": token ?? ""])
        return (data, response)
    }
}
