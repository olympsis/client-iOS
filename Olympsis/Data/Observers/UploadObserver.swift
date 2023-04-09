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
    
    func CreateUploadURL(folder: String, object: String) async throws -> String {
       return ""
    }
    
    func CreateDeleteURL(folder: String, object: String) async throws -> String {
        return ""
    }
    
    func UploadObject(url: String, object: Data) async throws -> Bool {
        return true
    }
    
    func UploadImage(location: String, data: Data) async -> String {
        return ""
    }
    
    
    func DeleteObject(path: String) async -> Bool {
        return true
    }
    
}
