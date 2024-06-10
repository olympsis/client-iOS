//
//  SystemModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/9/24.
//

import Foundation

struct LogEntry: Identifiable {
    var id = UUID()
    var date: Date
    var level: String
    var message: String
    var category: String
    var subsystem: String
}
