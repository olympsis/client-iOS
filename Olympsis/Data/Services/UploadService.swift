//
//  UploadService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Hermes
import SwiftUI
import Foundation

/// Network calls for object storage (image upload/delete). Both endpoints
/// need a merged `X-Filename` header the shared `APIService` `request`/
/// `requestRaw` helpers don't support (they only send the plain auth
/// headers), and image upload goes through `Courrier.Upload` rather than
/// `Courrier.Request` — so both methods call `http` directly instead of
/// going through the helpers.
class UploadService: APIService {

    let http: Courrier
    let decoder: JSONDecoder

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    /// Uploads image data to `location` and returns the server's moderation
    /// verdict. Deliberately does not check the status code — any failure
    /// (network, non-2xx, decode) is swallowed and returns nil, since callers
    /// only care whether a usable response came back.
    func UploadImage(location: String, fileName: String, data: Data) async -> ImageUploadResponse? {
        do {
            let type = ".jpeg"
            let headers = try await AppEnvironment.authHeaders(merging: ["X-Filename": fileName + type])
            let endpoint = Endpoint("/v1/storage" + location)
            let (respData, _) = try await http.Upload(endpoint: endpoint, fileName: fileName, fileType: .JPEG, data: data, headers: headers)
            return try decoder.decode(ImageUploadResponse.self, from: respData)
        } catch {
            return nil
        }
    }

    /// Deletes the object at `path` — the server identifies which object via
    /// the `X-Filename` header, not the path. Only a 200 counts as success;
    /// any other status or thrown error returns false.
    func DeleteObject(path: String, name: String) async -> Bool {
        do {
            let headers = try await AppEnvironment.authHeaders(merging: ["X-Filename": name])
            let endpoint = Endpoint("/v1/storage" + path)
            let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
            return (resp as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
