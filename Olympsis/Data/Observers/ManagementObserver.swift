//
//  ManagementObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/19/24.
//

import os
import Foundation

class ManagementObserver: ObservableObject {
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "management_observer")
    private let decoder = JSONDecoder()
    private let service = ManagementService()
    private let cacheService = CacheService()
    
    func createBugReport(report: BugReportDao) async throws -> Bool {
        let (_, resp) = try await service.createBugReport(dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func createFieldReport(report: FieldReportDao) async throws -> Bool {
        let (_, resp) = try await service.createFieldReport(dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func createEventReport(report: EventReportDao) async throws -> Bool {
        let (_, resp) = try await service.createEventReport(dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func getEventReports(id: String, status: String) async throws -> [EventReport]? {
        let (data, resp) = try await service.getEventReports(id: id, status: status)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        let object = try decoder.decode([EventReport].self, from: data)
        return object
    }
    
    func updateEventReport(id: String, report: EventReportDao) async throws -> Bool {
        let (_, resp) = try await service.updateEventReport(id: id, dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }
        return true
    }
    
    func createPostReport(report: PostReportDao) async throws -> Bool {
        let (_, resp) = try await service.createPostReport(dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func getPostReports(id: String, status: String) async throws -> [PostReport]? {
        let (data, resp) = try await service.getPostReports(id: id, status: status)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        do {
            let object = try decoder.decode([PostReport].self, from: data)
            return object
        } catch {
            log.error("failed to decode response: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updatePostReport(id: String, report: PostReportDao) async throws -> Bool {
        let (_, resp) = try await service.updatePostReport(id: id, dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }
        return true
    }
    
    func createMemberReport(report: MemberReportDao) async throws -> Bool {
        let (_, resp) = try await service.createMemberReport(dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }
    
    func getMemberReports(id: String, status: String) async throws -> [MemberReport]? {
        let (data, resp) = try await service.getMemberReports(id: id, status: status)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        let object = try decoder.decode([MemberReport].self, from: data)
        return object
    }
    
    func updateMemberReport(id: String, report: MemberReportDao) async throws -> Bool {
        let (_, resp) = try await service.updateMemberReport(id: id, dao: report)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            return false
        }
        return true
    }
}
