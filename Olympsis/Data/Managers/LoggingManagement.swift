//
//  LoggingManagement.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/9/24.
//

import os
import OSLog
import Foundation

class LoggingManagement {
    
    func fetchLogs(since date: Date, predicateFormat: String) async throws -> [LogEntry]? {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(date: date)
        let predicate = NSPredicate(format: predicateFormat)
        let entries = try store.getEntries(at: position, matching: predicate)

        var logs: [LogEntry] = []
        for entry in entries {
            try Task.checkCancellation()
            if let log = entry as? OSLogEntryLog {
                logs.append(
                    LogEntry(
                        date: entry.date,
                        level: log.level.description,
                        message: log.composedMessage,
                        category: log.category,
                        subsystem: log.subsystem
                    )
                )
            }
        }

        if logs.isEmpty { return nil }
        return logs
    }
}


extension OSLogEntryLog.Level {
  fileprivate var description: String {
    switch self {
    case .undefined: "Undefined"
    case .debug: "Debug"
    case .info: "Info"
    case .notice: "Notice"
    case .error: "Error"
    case .fault: "Fault"
    @unknown default: "Default"
    }
  }
}
