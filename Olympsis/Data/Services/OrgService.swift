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

/// Network calls for organization endpoints — search/lookup, creation,
/// applications, invitations, and pinned posts. The shared `APIService`
/// plumbing handles auth headers, status codes, and decoding.
class OrgService: APIService {

    static let shared = OrgService()

    let http: Courrier
    let decoder = JSONDecoder()
    private let log = Logger(subsystem: "com.olympsis.client", category: "org_service")

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// Fetches organizations for the given ids, in order.
    ///
    /// Bails out to `[]` on the very first failed lookup — a partial list is
    /// treated as unusable, not a partial success.
    func generateUserOrgs(orgIDs: [String]) async -> [Organization] {
        var orgs = [Organization]()
        for id in orgIDs {
            guard let org = await getOrganization(id: id) else {
                return [Organization]()
            }
            orgs.append(org)
        }
        return orgs
    }

    /// POST /v1/organizations
    ///
    /// Deliberately does not check the status code before decoding, matching
    /// the endpoint's original behavior.
    /// - Returns: the new organization's id.
    func createOrganization(organization: OrganizationDao) async throws -> String? {
        let (data, _) = try await requestRaw(.POST, Endpoint("/v1/organizations"), body: EncodeToData(organization))
        return try decoder.decode(CreateResponse.self, from: data).id
    }

    /// GET /v1/organizations?country=&state=
    func getOrganizations(country: String, state: String) async -> [Organization]? {
        do {
            let endpoint = Endpoint("/v1/organizations", queryItems: [
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "state", value: state)
            ])
            let object: OrganizationsResponse = try await request(.GET, endpoint)
            return object.organizations
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// GET /v1/organizations/{id}
    ///
    /// Deliberately does not check the status code before decoding, matching
    /// the endpoint's original behavior.
    func getOrganization(id: String) async -> Organization? {
        do {
            let (data, _) = try await requestRaw(.GET, Endpoint("/v1/organizations/\(id)"))
            return try decoder.decode(Organization.self, from: data)
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// Fetches an organization by ID, returning a cached copy when available.
    ///
    /// The first lookup for a given ID hits the network and stores the result
    /// in a shared in-memory cache. Subsequent lookups for the same ID return
    /// the cached organization without making another network call.
    ///
    /// Concurrent lookups for the *same* ID (e.g. many lazy-stack rows that
    /// share an owner appearing on screen at once) are coalesced into a single
    /// network request — later callers await the in-flight fetch rather than
    /// starting their own. This prevents a cache stampede where every row fires
    /// its own request before the first one has had a chance to populate the
    /// cache.
    func getCachedOrganization(id: String) async -> Organization? {
        await OrgCache.shared.organization(for: id) { [self] in
            await getOrganization(id: id)
        }
    }

    /// PUT /v1/organizations/{id}
    func updateOrganization(id: String, dto: OrganizationDao) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/organizations/\(id)"), body: EncodeToData(dto))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    // TODO: FOR ADMINS
    /// DELETE /v1/organizations/{id}
    func deleteOrganization(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/organizations/\(id)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    // APPLICATIONS

    /// POST /v1/organizations/applications
    /// - Returns: true if the application was created (201), false otherwise
    ///   or on failure.
    func createOrganizationApplication(app: OrganizationApplicationDao) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/organizations/applications"), body: EncodeToData(app))
            guard statusCode == 201 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// GET /v1/organizations/{id}/applications
    func getApplications(id: String) async -> [OrganizationApplication] {
        do {
            let (data, statusCode) = try await requestRaw(.GET, Endpoint("/v1/organizations/\(id)/applications"))
            guard statusCode == 200 else {
                return [OrganizationApplication]()
            }
            return try decoder.decode([OrganizationApplication].self, from: data)
        } catch {
            log.error("\(error)")
        }
        return [OrganizationApplication]()
    }

    /// PUT /v1/organizations/applications/{id}
    func updateApplication(id: String, app: OrganizationApplicationDao) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/organizations/applications/\(id)"), body: EncodeToData(app))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    // INVITATIONS

    /// POST /v1/organizations/invitations
    ///
    /// Accepts 200 or 201 as success — servers differ on which they return
    /// for "created".
    func createInvitation(data: InvitationDTO) async -> Invitation? {
        do {
            let (respData, statusCode) = try await requestRaw(.POST, Endpoint("/v1/organizations/invitations"), body: EncodeToData(data))
            guard statusCode == 200 || statusCode == 201 else {
                return nil
            }
            return try decoder.decode(Invitation.self, from: respData)
        } catch {
            log.error("Failed to create invitation: \(error.localizedDescription)")
        }
        return nil
    }

    /// PUT /v1/organizations/invitations/{id}
    func updateInvitation(data: InvitationDTO) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/organizations/invitations/\(data.id ?? "")"), body: EncodeToData(data))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to update invitation: \(error.localizedDescription)")
        }
        return false
    }

    /// PUT /v1/organizations/{id}/post/{postId}
    func pinPost(id: String, postId: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/organizations/\(id)/post/\(postId)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// PUT /v1/organizations/{id}/post
    func unPinPost(id: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.PUT, Endpoint("/v1/organizations/\(id)/post"))
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

/// Process-wide in-memory cache of fetched organizations keyed by ID.
///
/// Backed by an actor so concurrent reads/writes from different async contexts
/// are serialized safely. The cache is shared (via `shared`) across every
/// `OrgService` instance — both `session.orgService` and `OrgService.shared`
/// — so a given organization is only fetched from the network once per app run.
actor OrgCache {
    static let shared = OrgCache()

    /// Completed lookups, keyed by org ID.
    private var storage: [String: Organization] = [:]
    /// Lookups currently in flight, keyed by org ID. Lets concurrent callers
    /// for the same ID join one request instead of each starting their own.
    private var inFlight: [String: Task<Organization?, Never>] = [:]

    /// Returns the organization for `id`, performing `fetch` only when it is
    /// neither already cached nor currently being fetched.
    ///
    /// All of the read-cache / join-in-flight / start-new-fetch decision making
    /// happens inside this single actor method, so it is atomic: two callers
    /// racing on the same ID can never both kick off a network request.
    func organization(
        for id: String,
        fetch: @Sendable @escaping () async -> Organization?
    ) async -> Organization? {
        // Already resolved — hand back the cached value.
        if let cached = storage[id] {
            return cached
        }
        // A fetch is already running for this ID — await its result.
        if let task = inFlight[id] {
            return await task.value
        }

        // First caller for this ID: start the fetch and register it so others
        // can join. Note: awaiting `task.value` suspends this actor, allowing
        // those other callers to observe `inFlight[id]` above.
        let task = Task { await fetch() }
        inFlight[id] = task
        let org = await task.value
        inFlight[id] = nil

        if let org {
            storage[id] = org
        }
        return org
    }
}
