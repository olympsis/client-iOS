//
//  ClubObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class ClubObserver: ObservableObject{
    private let decoder: JSONDecoder
    private let clubService: ClubService
    
    @Published var isLoading = true
    @Published var clubsCount = 0
    @Published var clubs = [Club]()
    @Published var myClubs = [Club]()
    @Published var applications = [NewClubApplication]()
    
    
    init(){
        decoder = JSONDecoder()
        clubService = ClubService()
    }
    
    /// Calls the club service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func getClubs() async {
        do {
            let resp = try await clubService.getClubs()
            let object = try decoder.decode(ClubsResponse.self, from: resp)
            await MainActor.run { // TODO: Check later about threads
                self.clubs = object.clubs
                self.clubsCount = object.totalClubs
            }
        } catch {
            print(error)
        }
    }
    
    func getClub(id: String) async -> Club?{
        do {
            let res = try await clubService.getClub(id: id)
            let object = try decoder.decode(Club.self, from: res)
            return object
        } catch {
            print(error)
        }
        return nil
    }
    
    func getClubApplications() async {
        do {
            let resp = try await clubService.getClubs()
            let object = try decoder.decode(ClubsResponse.self, from: resp)
            await MainActor.run { // TODO: Check later about threads
                self.clubs = object.clubs
                self.clubsCount = object.totalClubs
            }
        } catch (let err) {
            print(err)
        }
    }
    
    func createClubApplication(clubId: String) async -> Bool {
        let req = ClubApplicationRequestDao(clubId: clubId)
        do {
            return try await clubService.createClubApplication(req: req)
        } catch (let err) {
            print(err)
            return false
        }
    }
    
    func createClub(dao: ClubDao) async throws -> Club {
        let res = try await clubService.createClub(dao: dao)
        let object = try decoder.decode(Club.self, from: res)
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
            print(error)
        }
        return [ClubApplication]()
    }
    
    func updateApplication(id: String, dao: UpdateApplicationDao) async -> Bool {
        do {
            let res = try await clubService.updateApplication(id: id, dao: dao)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                print((res as? HTTPURLResponse)?.statusCode)
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
}
