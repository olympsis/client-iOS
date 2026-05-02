//
//  ClubService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import Hermes
import SwiftUI
import Foundation

class ClubService {

    private var http: Courrier

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    @MainActor
    func getClubs(c: String, s: String, l: GeoJSON?=nil, r: Double?=nil, tags: String?=nil, sports: String?=nil) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        var queries = [
            URLQueryItem(name: "country", value: c),
            URLQueryItem(name: "state", value: s)
        ]

        if tags != nil && !tags!.isEmpty {
            queries.append(URLQueryItem(name: "tags", value: tags))
        }

        if sports != nil && !sports!.isEmpty {
            queries.append(URLQueryItem(name: "sports", value: sports))
        }

        if let location = l {
            queries.append(
                URLQueryItem(name: "location", value: "\(location.coordinates[1]),\(location.coordinates[0])")
            )
        }

        if let radius = r {
            queries.append(
                URLQueryItem(name: "radius", value: String(radius))
            )
        }

        let endpoint = Endpoint("/v1/clubs", queryItems: queries)
        let (data, resp) = try await http.Request(.GET, endpoint, headers: headers)
        return (data, resp)
    }

    func getUserClubs(clubs: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/user", queryItems: [
            URLQueryItem(name: "clubs", value: clubs)
        ])
        let (data, resp) = try await http.Request(.GET, endpoint, headers: headers)
        return (data, resp)
    }

    func getClub(id: String) async throws -> Data {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: headers)
        return data
    }

    func createClub(club: ClubDao) async throws -> Data {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs")
        let (data, _) = try await http.Request(.POST, endpoint, body: EncodeToData(club), headers: headers)
        return data
    }

    func updateClub(id: String, club: ClubDao) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(club), headers: headers)
        return resp
    }

    func leaveClub(id: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/leave")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: headers)
        return resp
    }

    // TODO: FOR ADMINS
    func deleteClub(id: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)")
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return resp
    }

    func createClubApplication(id: String) async throws -> Bool {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/applications")

        let (_, resp) = try await http.Request(.POST, endpoint, headers: headers)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            return false
        }
        return true
    }

    func deleteClubApplication(id: String) async throws -> Data {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/applications/\(id)")

        let (data, _) = try await http.Request(.DELETE, endpoint, headers: headers)
        return data
    }

    func getApplications(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/applications")

        let (data, resp) = try await http.Request(.GET, endpoint, headers: headers)
        return (data, resp)
    }

    func updateApplication(id: String, appID: String, req: ApplicationUpdateRequest) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/applications/\(appID)")

        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(req), headers: headers)
        return resp
    }

    func changeRank(id: String, memberId: String, role: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let req = ChangeRoleRequest(role: role)
        let endpoint = Endpoint("/v1/clubs/\(id)/members/\(memberId)/rank")
        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(req), headers: headers)
        return resp
    }

    func kickMember(id: String, memberId: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/members/\(memberId)/kick")

        let (_, resp) = try await http.Request(.PUT, endpoint, headers: headers)
        return resp
    }

    func pinPost(id: String, postId: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/post/\(postId)")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: headers)
        return resp
    }

    func unPinPost(id: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/clubs/\(id)/post")
        let (_, resp) = try await http.Request(.PUT, endpoint, headers: headers)
        return resp
    }
}
