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
    @Published var applications = [ClubApplication]()
    
    
    init(){
        decoder = JSONDecoder()
        clubService = ClubService()
    }
    
    /// Calls the club service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func fetchClubs() async {
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
    
    func fetchClubApplications() async {
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
            return try await clubService.CreateClubApplication(req: req)
        } catch (let err) {
            print(err)
            return false
        }
    }
}
