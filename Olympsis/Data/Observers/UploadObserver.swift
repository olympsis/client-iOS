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
    
    
    func UploadImage(location: String, fileName: String, data: Data) async -> Bool {
        do {
            let (_, res) = try await uploadService.UploadObject(url: location, fileType: "image", fileName: fileName, body: data)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    
    func DeleteObject(path: String, name: String) async -> Bool {
        do {
            let (_, res) = try await uploadService.DeleteObject(url: path, fileName: name)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
}
