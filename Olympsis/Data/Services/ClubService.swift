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

/// Network calls for club endpoints — search/lookup, creation, membership
/// management, applications, and pinned posts. The shared `APIService`
/// plumbing handles auth headers, status codes, and decoding.
class ClubService: APIService {

    static let shared = ClubService()

    let http: Courrier
    let decoder = JSONDecoder()
    private let log = Logger(subsystem: "com.olympsis.client", category: "club_service")

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// GET /v1/clubs?country=&state=&tags=&sports=&location=&radius=
    ///
    /// 204 means no clubs matched the filters — returns `[]`, distinct from
    /// `nil`, which means the request failed.
    @MainActor
    func getClubs(country: String, state: String, location: GeoJSON? = nil, radius: Double? = nil, tags: String? = nil, sports: String? = nil) async -> [Club]? {
        var queries = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "state", value: state)
        ]

        if let tags = tags, !tags.isEmpty {
            queries.append(URLQueryItem(name: "tags", value: tags))
        }

        if let sports = sports, !sports.isEmpty {
            queries.append(URLQueryItem(name: "sports", value: sports))
        }

        if let location = location {
            queries.append(
                URLQueryItem(name: "location", value: "\(location.coordinates[1]),\(location.coordinates[0])")
            )
        }

        if let radius = radius {
            queries.append(
                URLQueryItem(name: "radius", value: String(radius))
            )
        }

        do {
            let (data, statusCode) = try await requestRaw(.GET, Endpoint("/v1/clubs", queryItems: queries))
            guard statusCode == 200 else {
                return statusCode == 204 ? [] : nil
            }
            return try decoder.decode(ClubsResponse.self, from: data).clubs
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// GET /v1/clubs/user?clubs=id1,id2,...
    /// - Returns: the matching clubs, or `[]` on any failure.
    func getUserClubs(clubs: [String]) async -> [Club] {
        do {
            let object: ClubsResponse = try await request(.GET, Endpoint("/v1/clubs/user", queryItems: [
                URLQueryItem(name: "clubs", value: clubs.joined(separator: ","))
            ]))
            return object.clubs
        } catch {
            log.error("\(error)")
        }
        return [Club]()
    }

    /// GET /v1/clubs/{id}
    ///
    /// Deliberately does not check the status code — decode-or-nil, matching
    /// the endpoint's original behavior.
    func getClub(id: String) async -> Club? {
        do {
            let (data, _) = try await requestRaw(.GET, Endpoint("/v1/clubs/\(id)"))
            return try decoder.decode(Club.self, from: data)
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// POST /v1/clubs
    ///
    /// Deliberately does not check the status code before decoding, matching
    /// the endpoint's original behavior.
    /// - Returns: the new club's id.
    func createClub(club: ClubDao) async throws -> String? {
        let (data, _) = try await requestRaw(.POST, Endpoint("/v1/clubs"), body: EncodeToData(club))
        return try decoder.decode(CreateResponse.self, from: data).id
    }

    /// POST /v1/clubs/{id}/applications
    /// - Returns: true if the application was created (201), false otherwise
    ///   or on failure.
    func createClubApplication(clubId: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/clubs/\(clubId)/applications"))
            guard statusCode == 201 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// GET /v1/clubs/{id}/applications
    func getApplications(id: String) async -> [ClubApplication] {
        do {
            let object: ClubApplicationsResponse = try await request(.GET, Endpoint("/v1/clubs/\(id)/applications"))
            return object.applications
        } catch {
            log.error("\(error)")
        }
        return [ClubApplication]()
    }

    /// PUT /v1/clubs/{id}/applications/{appID}
    func updateApplication(id: String, appID: String, req: ApplicationUpdateRequest) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)/applications/\(appID)"), body: EncodeToData(req))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/clubs/{id}/members/{memberId}/rank
    func changeMemberRank(id: String, memberId: String, role: String) async -> Bool {
        do {
            let req = ChangeRoleRequest(role: role)
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)/members/\(memberId)/rank"), body: EncodeToData(req))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/clubs/{id}/members/{memberId}/kick
    func kickMember(id: String, memberId: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)/members/\(memberId)/kick"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/clubs/{id}
    func updateClub(id: String, dto: ClubDao) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)"), body: EncodeToData(dto))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to update club: \(error.localizedDescription)")
        }
        return false
    }

    // TODO: FOR ADMINS
    /// DELETE /v1/clubs/{id}
    func deleteClub(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/clubs/\(id)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/clubs/{id}/leave
    func leaveClub(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)/leave"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/clubs/{id}/post/{postId}
    func pinPost(id: String, postId: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)/post/\(postId)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/clubs/{id}/post
    func unPinPost(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/clubs/\(id)/post"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
}
