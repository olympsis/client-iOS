//
//  OrgService.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import os
import Hermes
import SwiftUI
import Foundation

class OrgService {

    private var http: Courrier

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func getOrganizations(c: String, s: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations", queryItems: [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ])
        let (data, resp) = try await http.Request(.GET, endpoint, headers: headers)
        return (data, resp)
    }

    func getOrganization(id: String) async throws -> Data {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: headers)
        return data
    }

    func createOrganization(org: OrganizationDao) async throws -> Data {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations")
        let (data, _) = try await http.Request(.POST, endpoint, body: EncodeToData(org), headers: headers)
        return data
    }

    func updateOrganization(id: String, dto: OrganizationDao) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/\(id)")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(dto), headers: headers)
        return resp
    }

    // TODO: FOR ADMINS
    func deleteOrganization(id: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/\(id)")
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return resp
    }

    // APPLICATIONS

    func createApplication(app: OrganizationApplicationDao) async throws -> Bool {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/applications")

        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(app), headers: headers)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }

    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/\(id)/applications")
        let (data, resp) = try await http.Request(.GET, endpoint, headers: headers)
        return (data, resp)
    }

    func updateApplication(id: String, app: OrganizationApplicationDao) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/applications/\(id)")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(app), headers: headers)
        return resp
    }

    func deleteApplication(id: String) async throws -> Data {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/applications/\(id)")
        let (data, _) = try await http.Request(.DELETE, endpoint, headers: headers)
        return data
    }

    // INVITATIONS

    func createInvitation(data: InvitationDTO) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/invitations")
        return try await http.Request(.POST, endpoint, body: EncodeToData(data), headers: headers)
    }

    func updateInvitation(data: InvitationDTO) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/invitations/\(data.id ?? "")")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(data), headers: headers)
        return resp
    }

    func pinPost(id: String, postId: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/\(id)/post/\(postId)")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: headers)
        return resp
    }

    func unPinPost(id: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/organizations/\(id)/post")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: headers)
        return resp
    }
}
