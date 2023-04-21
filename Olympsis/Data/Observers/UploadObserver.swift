//
//  UploadObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/4/22.
//

import Foundation
import Hermes
class UploadObserver: ObservableObject {
    private let decoder: JSONDecoder
    private let uploadService: UploadService
    
    init() {
        decoder = JSONDecoder()
        uploadService = UploadService()
    }
    
    
    func UploadObject(url: String, object: Data) async throws -> Bool {
        return true
    }
    
    func UploadImage(location: String, fileName: String, data: Data) async -> String {
        do {
            try await uploadService.UploadObject(url: location, fileType: "image", fileName: fileName, body: data)
            return location
        } catch {
            print(error)
            return ""
        }
    }
    
    
    func DeleteObject(path: String, name: String) async -> Bool {
        do {
            let (_, res) = try await uploadService.DeleteObject(url: path, name: name)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
    
}
