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
    
    @Published var isLoading = true
    @Published var clubsCount = 0
    @Published var clubs = [Club]()
    @Published var myClubs = [Club]()
    @Published var applications = [NewClubApplication]()
    
    
    /// Calls the club service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func getClubs(country: String, state: String) async {
        do {
            let (data, res) = try await clubService.getClubs(c: country, s: state)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return
            }
            let object = try decoder.decode(ClubsResponse.self, from: data)
            await MainActor.run { // TODO: Check later about threads
                self.clubs = object.clubs
                self.clubsCount = object.totalClubs
            }
        } catch {
            log.error("\(error)")
        }
    }
    
    func getClub(id: String) async -> Club? {
        do {
            let res = try await clubService.getClub(id: id)
            let object = try decoder.decode(Club.self, from: res)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func createClubApplication(clubId: String) async -> Bool {
        do {
            return try await clubService.createClubApplication(id: clubId)
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func createClub(club: Club) async throws -> CreateClubResponse {
        let res = try await clubService.createClub(club: club)
        let object = try decoder.decode(CreateClubResponse.self, from: res)
        cacheService.cacheClubAdminToken(id: object.club.id!, token: object.token)
        return object
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
    
    func updateApplication(app: ClubApplication) async -> Bool {
        do {
            let res = try await clubService.updateApplication(app: app)
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
            let dao = ChangeRankDao(role: role)
            let res = try await clubService.changeRank(id: id, memberId: memberId, dao: dao)
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
}
