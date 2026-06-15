//
//  OrgObserver.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import os
import Foundation

/// Org Observer is a class object that keeps tracks of and fetches organizations
class OrgObserver: ObservableObject{
    
    static let shared = OrgObserver()
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "club_observer")
    private let decoder = JSONDecoder()
    private let orgService = OrgService()
    private let cacheService = CacheService()
    
    func generateUserOrgs(orgIDs: [String]) async -> [Organization] {
        var orgs = [Organization]()
        for id in orgIDs {
            let resp = await getOrganization(id: id)
            guard let r = resp else {
                return [Organization]()
            }
            orgs.append(r)
        }
        return orgs
    }
    
    func createOrganization(organization: OrganizationDao) async throws -> String? {
        let res = try await orgService.createOrganization(org: organization)
        let object = try decoder.decode(CreateResponse.self, from: res)
        return object.id
    }
    
    /// Calls the club service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func getOrganizations(country: String, state: String) async -> [Organization]? {
        do {
            let (data, res) = try await orgService.getOrganizations(c: country, s: state)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(OrganizationsResponse.self, from: data)
            return object.organizations
        } catch {
            log.error("\(error)")
            return nil
        }
    }
    
    func getOrganization(id: String) async -> Organization? {
        do {
            let res = try await orgService.getOrganization(id: id)
            let object = try decoder.decode(Organization.self, from: res)
            return object
        } catch {
            log.error("\(error)")
            return nil
        }
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

    func updateOrganization(id: String, dto: OrganizationDao) async -> Bool {
        do {
            let res = try await orgService.updateOrganization(id: id, dto: dto)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func deleteOrganization(id: String) async -> Bool {
        do {
            let res = try await orgService.deleteOrganization(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func createOrganizationApplication(app: OrganizationApplicationDao) async -> Bool {
        do {
            return try await orgService.createApplication(app: app)
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func getApplications(id: String) async -> [OrganizationApplication] {
        do {
            let (data, res) = try await orgService.getApplications(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return [OrganizationApplication]()
            }
            return try decoder.decode([OrganizationApplication].self, from: data)
        } catch {
            log.error("\(error)")
            return [OrganizationApplication]()
        }
    }
    
    func updateApplication(id: String, app: OrganizationApplicationDao) async -> Bool {
        do {
            let res = try await orgService.updateApplication(id: id, app: app)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func createInvitation(data: InvitationDTO) async -> Invitation? {
        do {
            let (data, res) = try await orgService.createInvitation(data: data)
            guard (res as? HTTPURLResponse)?.statusCode == 201 || (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            return try decoder.decode(Invitation.self, from: data)
        } catch {
            log.error("Failed to create invitation: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateInvitation(data: InvitationDTO) async -> Bool {
        do {
            let resp = try await orgService.updateInvitation(data: data)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to update invitation: \(error.localizedDescription)")
            return false
        }
    }
    
    func pinPost(id: String, postId: String) async -> Bool {
        do {
            let res = try await orgService.pinPost(id: id, postId: postId)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func unPinPost(id: String) async -> Bool {
        do {
            let res = try await orgService.unPinPost(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
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
/// `OrgObserver` instance — both `session.orgObserver` and `OrgObserver.shared`
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
