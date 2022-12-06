//
//  UploadObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/4/22.
//

import Foundation

class UploadObserver: ObservableObject {
    private let decoder: JSONDecoder
    private let uploadService: UploadService
    
    init() {
        decoder = JSONDecoder()
        uploadService = UploadService()
    }
    
    func CreateUploadURL(folder: String, object: String) async throws -> String {
        let response = try await uploadService.GetUploadUrl(folder: folder, object: object)
        let url = try decoder.decode(String.self, from: response)
        return url
    }
    
    func CreateDeleteURL(folder: String, object: String) async throws -> String {
        let response = try await uploadService.GetDeleteUrl(folder: folder, object: object)
        let url = try decoder.decode(String.self, from: response)
        return url
    }
    
    func UploadObject(url: String, object: Data) async throws -> Bool {
        do {
            let response = try await uploadService.UploadObject(url: url, body: object)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
}
