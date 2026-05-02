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

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func UploadObject(url: String, fileType: String, fileName: String, body: Data) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/v1/storage" + url)

        let (data, resp) = try await _uploadImage(endpoint: endpoint, name: fileName, data: body)
        return (data, resp)
    }

    func DeleteObject(url: String, fileName: String) async throws -> (Data, URLResponse){
        let headers = try await AppEnvironment.authHeaders(merging: ["X-Filename": fileName])
        let endpoint = Endpoint("/v1/storage" + url)

        let (data, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return (data, resp)
    }

    func _uploadImage(endpoint: Endpoint, name: String, data: Data) async throws -> (Data, URLResponse) {
        let type = ".jpeg"
        let headers = try await AppEnvironment.authHeaders(merging: ["X-Filename": name + type])
        let (data, response) = try await self.http.Upload(endpoint: endpoint, fileName: name, fileType: .JPEG, data: data, headers: headers)
        return (data, response)
    }
}
