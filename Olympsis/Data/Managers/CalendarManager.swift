//
//  CalendarManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/27/25.
//

import os
import EventKit
import Foundation

class CalendarManager {
    
    private let store = EKEventStore()
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "calendar_manager")
    
    func requestEventsAccess() async throws -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            log.error("Falied to request calendar access: \(error)")
            return false
        }
    }
    
    func createEvent(withTitle title: String, startDate: Date, endDate: Date) async throws -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        try store.save(event, span: .thisEvent)
        return event
    }
    
    func removeEvent(_ event: EKEvent) async throws {
        try store.remove(event, span: .thisEvent)
    }
}
