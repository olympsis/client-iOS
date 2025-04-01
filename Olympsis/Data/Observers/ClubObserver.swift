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
    
    static let shared = ClubObserver()
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "club_observer")
    private let decoder = JSONDecoder()
    private let clubService = ClubService()
    private let cacheService = CacheService()
    
    @Published var myClubs = [Club]()
    
    /// Calls the club service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func getClubs(country: String, state: String, location: GeoJSON? = nil, radius: Double? = nil, tags: String? = nil, sports: String? = nil) async -> [Club]? {
        do {
            let (data, res) = try await clubService.getClubs(c: country, s: state, l: location, r: radius, tags: tags, sports: sports)
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
    
    func getUserClubs(clubs: [String]) async -> [Club] {
        do {
            let (data, res) = try await clubService.getUserClubs(clubs: clubs.joined(separator: ","))
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return [Club]()
            }
            let object = try decoder.decode(ClubsResponse.self, from: data)
            return object.clubs
        } catch {
            log.error("\(error)")
            return [Club]()
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
    
    func createClub(club: ClubDao) async throws -> String? {
        let res = try await clubService.createClub(club: club)
        let object = try decoder.decode(CreateResponse.self, from: res)
        return object.id
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
    
    func updateClub(id: String, dto: ClubDao) async -> Bool {
        do {
            let res = try await clubService.updateClub(id: id, club: dto)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to update club: \(error.localizedDescription)")
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
    
    func pinPost(id: String, postId: String) async -> Bool {
        do {
            let res = try await clubService.pinPost(id: id, postId: postId)
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
            let res = try await clubService.unPinPost(id: id)
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
