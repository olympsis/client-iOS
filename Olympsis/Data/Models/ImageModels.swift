//
//  ImageModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/18/24.
//

import Foundation

struct ImageUploadResponse: Codable {
    let url: String?
    let score: Int
    let reason: String?
}
