//
//  UploadObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/4/22.
//

import Foundation
import FirebaseStorage

class UploadObserver: ObservableObject {
    private let decoder: JSONDecoder
    private let uploadService: UploadService
    private let storage = Storage.storage()
    
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
    
    func UploadImage(location: String, data: Data) async -> String {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        return await _uploadObject(o: data, m: metadata, l: location)
    }
    
    
    func _uploadObject(o: Data, m: StorageMetadata, l: String) async -> String {
        let storageRef = storage.reference().child(l)
        do{
            let data = try await storageRef.putDataAsync(o, metadata: m)
            if let url = data.path {
                return url
            }
            return "error"
        } catch {
            print(error)
            return "error"
        }
    }
    
    func DeleteObject(path: String) async -> Bool {
        let storageRef = storage.reference().child(path)
        do{
            try await storageRef.delete()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
}
