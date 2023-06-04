//
//  ClubObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class ClubObserver: ObservableObject{
    
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "club_observer")
    private let decoder = JSONDecoder()
    private let clubService = ClubService()
    private let cacheService = CacheService()
    
    @Published var myClubs = [Club]()
    
    func generateUserClubs(clubIDs: [String]) async -> [Club] {
        var clubs = [Club]()
        for id in clubIDs {
            let resp = await getClub(id: id)
            guard let r = resp else {
                return [Club]()
            }
            clubs.append(r.club)
            guard let tk = r.token else {
                return clubs
            }
            cacheService.cacheClubAdminToken(id: r.club.id!, token: tk)
        }
        return clubs
    }
    
    /// Calls the club service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func getClubs(country: String, state: String) async -> [Club]? {
        do {
            let (data, res) = try await clubService.getClubs(c: country, s: state)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(ClubsResponse.self, from: data)
            return object.clubs
        } catch {
            log.error("\(error)")
            return nil
        }
    }
    
    func getClub(id: String) async -> ClubResponse? {
        do {
            let res = try await clubService.getClub(id: id)
            let object = try decoder.decode(ClubResponse.self, from: res)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func createClub(club: Club) async throws -> Club {
        let res = try await clubService.createClub(club: club)
        let object = try decoder.decode(CreateClubResponse.self, from: res)
        cacheService.cacheClubAdminToken(id: object.club.id!, token: object.token)
        return object.club
    }
    
    func createClubApplication(clubId: String) async -> Bool {
        do {
            return try await clubService.createClubApplication(id: clubId)
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func getApplications(id: String) async -> [ClubApplication] {
        do {
            let (data, res) = try await clubService.getApplications(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return [ClubApplication]()
            }
            let object = try decoder.decode(ClubApplicationsResponse.self, from: data)
            return object.applications
        } catch {
            log.error("\(error)")
        }
        return [ClubApplication]()
    }
    
    func updateApplication(id: String, appID: String, req: ApplicationUpdateRequest) async -> Bool {
        do {
            let res = try await clubService.updateApplication(id: id, appID: appID, req: req)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func changeMemberRank(id: String, memberId: String, role: String) async -> Bool {
        do {
            let res = try await clubService.changeRank(id: id, memberId: memberId, role: role)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func kickMember(id: String, memberId: String) async -> Bool {
        do {
            let res = try await clubService.kickMember(id: id, memberId: memberId)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func deleteClub(id: String) async -> Bool {
        do {
            let res = try await clubService.deleteClub(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func leaveClub(id: String) async -> Bool {
        do {
            let res = try await clubService.leaveClub(id: id)
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
