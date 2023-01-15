//
//  Message.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import Foundation

struct Message: Codable, Identifiable {
    let id: String
    let type: String
    let from: String
    let body: String
    let timestamp: Int64
}
