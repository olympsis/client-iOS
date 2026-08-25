//
//  ManagementService.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/11/24.
//

import Hermes
import Foundation

/// This service is in charge of handling requests that the user may want to create that has to do with bug reporting, reporting bad actors and giving feedback.
class ManagementService: APIService {

    let http: Courrier
    let decoder = JSONDecoder()

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// GET /v1/health/wsg — used pre-login to decide whether sign in should be enabled, so it
    /// deliberately skips auth headers and swallows every failure to `false`.
    func wsg() async -> Bool {
        do {
            let endpoint = Endpoint("/v1/health/wsg")
            let (_, res) = try await http.Request(.GET, endpoint)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
        } catch {
            return false
        }

        return true
    }

    /// GET /v1/system/config — the tags/sports config SessionStore seeds itself with at launch.
    func config() async throws -> ApplicationConfiguration {
        return try await request(.GET, Endpoint("/v1/system/config"))
    }

    /// GET /v1/locales/countries — swallows every failure to `[]`.
    func getCountries() async throws -> [Country] {
        do {
            let endpoint = Endpoint("/v1/locales/countries")
            let (data, res) = try await http.Request(.GET, endpoint)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return []
            }

            return try JSONDecoder().decode([Country].self, from: data)
        } catch {
            return []
        }
    }

    /// GET /v1/locales/countries/{id}/administrativeAreas — swallows every failure to `[]`.
    func getAdministrativeAreas(_ country: Country) async throws -> [AdministrativeArea] {
        do {
            let endpoint = Endpoint("/v1/locales/countries/\(country.id)/administrativeAreas")
            let (data, res) = try await http.Request(.GET, endpoint)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return []
            }

            return try JSONDecoder().decode([AdministrativeArea].self, from: data)
        } catch {
            return []
        }
    }

    /// GET /v1/locales/administrativeAreas/{id}/subAdministrativeAreas — swallows every failure to `[]`.
    func getSubAdministrativeAreas(_ admin: AdministrativeArea) async throws -> [SubAdministrativeArea] {
        do {
            let endpoint = Endpoint("/v1/locales/administrativeAreas/\(admin.id)/subAdministrativeAreas")
            let (data, res) = try await http.Request(.GET, endpoint)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return []
            }

            return try JSONDecoder().decode([SubAdministrativeArea].self, from: data)
        } catch {
            return []
        }
    }

    /// POST /v1/report/bugs — true once the report is recorded (201).
    func createBugReport(report: BugReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/report/bugs"), body: EncodeToData(report))
        return statusCode == 201
    }

    /// POST /v1/report/fields — true once the report is recorded (201).
    func createFieldReport(report: FieldReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/report/fields"), body: EncodeToData(report))
        return statusCode == 201
    }

    /// POST /v1/report/events — true once the report is recorded (201).
    func createEventReport(report: EventReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/report/events"), body: EncodeToData(report))
        return statusCode == 201
    }

    /// GET /v1/report/events?groupID=&status= — nil on a non-200, otherwise the decoded page.
    func getEventReports(id: String, status: String) async throws -> [EventReport]? {
        let endpoint = Endpoint("/v1/report/events", queryItems: [URLQueryItem(name: "groupID", value: id), URLQueryItem(name: "status", value: status)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else {
            return nil
        }
        return try decoder.decode([EventReport].self, from: data)
    }

    /// PUT /v1/report/events/{id} — true once the report is updated (200).
    func updateEventReport(id: String, report: EventReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/report/events/\(id)"), body: EncodeToData(report))
        return statusCode == 200
    }

    /// POST /v1/report/posts — true once the report is recorded (201).
    func createPostReport(report: PostReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/report/posts"), body: EncodeToData(report))
        return statusCode == 201
    }

    /// GET /v1/report/posts?groupID=&status= — nil on a non-200, otherwise the decoded page.
    func getPostReports(id: String, status: String) async throws -> [PostReport]? {
        let endpoint = Endpoint("/v1/report/posts", queryItems: [URLQueryItem(name: "groupID", value: id), URLQueryItem(name: "status", value: status)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else {
            return nil
        }
        return try decoder.decode([PostReport].self, from: data)
    }

    /// PUT /v1/report/posts/{id} — true once the report is updated (200).
    func updatePostReport(id: String, report: PostReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/report/posts/\(id)"), body: EncodeToData(report))
        return statusCode == 200
    }

    /// POST /v1/report/members — true once the report is recorded (201).
    func createMemberReport(report: MemberReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/report/members"), body: EncodeToData(report))
        return statusCode == 201
    }

    /// GET /v1/report/members?groupID=&status= — nil on a non-200, otherwise the decoded page.
    func getMemberReports(id: String, status: String) async throws -> [MemberReport]? {
        let endpoint = Endpoint("/v1/report/members", queryItems: [URLQueryItem(name: "groupID", value: id), URLQueryItem(name: "status", value: status)])
        let (data, statusCode) = try await requestRaw(.GET, endpoint)
        guard statusCode == 200 else {
            return nil
        }
        return try decoder.decode([MemberReport].self, from: data)
    }

    /// PUT /v1/report/members/{id} — true once the report is updated (200).
    func updateMemberReport(id: String, report: MemberReportDao) async throws -> Bool {
        let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/report/members/\(id)"), body: EncodeToData(report))
        return statusCode == 200
    }
}
