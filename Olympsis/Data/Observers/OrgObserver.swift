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
    
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "club_observer")
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
    
    func createOrganization(organization: Organization) async throws -> Organization {
        let res = try await orgService.createOrganization(org: organization)
        let object = try decoder.decode(Organization.self, from: res)
        return object
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
    
    func createOrganizationApplication(app: OrganizationApplication) async -> Bool {
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
    
    func updateApplication(id: String, app: OrganizationApplication) async -> Bool {
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
    
    func createInvitation(data: Invitation) async -> Invitation? {
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
    
    func updateInvitation(data: Invitation) async -> Bool {
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
