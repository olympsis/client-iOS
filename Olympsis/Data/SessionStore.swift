//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import SwiftUI
import Foundation

class SessionStore: ObservableObject {

    private var token: String?
    
    private var firstName: String?
    private var lastName: String?
    private var email: String?
    private var uuid: String?
    
    @Published var user: UserStore?
    
    @Published var fields = [Field]()    // Fields Cache
    @Published var clubs = [Club]()      // Clubs Cache
    @Published var events = [Event]()    // Events Cache
    @Published var posts = [Post]()      // Posts Cache
    
    @Published var myClubs = [Club]()
    
//    @Published var dataLoader: DevDataLoader
    
    
    let cacheService: CacheService
    let userObserver: UserObserver
    let clubObserver: ClubObserver
    let postObserver: PostObserver
    
    init() {
        
        // DEV DATA
//        dataLoader = DevDataLoader()
        cacheService = CacheService()
        userObserver = UserObserver()
        clubObserver = ClubObserver()
        postObserver = PostObserver()
        
        fetchDataFromCache()
//        dataLoader.getData() // DEV DATA
//        self.fields = dataLoader.getFields()
//        self.clubs = dataLoader.getClubs()
//        self.events = dataLoader.getEvents()
    }
    
    func fetchDataFromCache() {
        (firstName, lastName, email, uuid) = cacheService.fetchPartialUserData()
    }
    
    func fetchToken() {
        self.token = cacheService.fetchToken()
    }
    
    func getFirstName() -> String {
        return firstName ?? "unnamed";
    }
    
    func getLastName() -> String {
        return lastName ?? "user";
    }
    
    func getUUID() -> String {
        return uuid ?? "error";
    }
    
    /// This function fetches user data from storage and the backend. It combines the two and stores it in the session.
    func generateUpdatedUserData() async {
        if var storedUser = cacheService.fetchUser() {
            do {
                let updatedData = try await userObserver.GetUserData()
                storedUser.uuid = updatedData.uuid
                storedUser.username = updatedData.username
                storedUser.bio = updatedData.bio
                storedUser.imageURL = updatedData.imageURL
                storedUser.isPublic = updatedData.isPublic
                storedUser.sports = updatedData.sports
                storedUser.clubs = updatedData.clubs
                storedUser.badges = updatedData.badges
                storedUser.trophies = updatedData.trophies
                storedUser.friends = updatedData.friends
            } catch {
                // do nothing we will just work with old stored data instead
                print(error)
                print("Failed to get user data from the backend")
            }
        } else {
            // if there is no stored user then use updated the one from the backend
            do {
                let updatedData = try await userObserver.GetUserData()
                (firstName, lastName, email, uuid) = cacheService.fetchPartialUserData()
                await MainActor.run {
                    self.user = UserStore(firstName: firstName!, lastName: lastName!, email: email!,
                                          uuid: updatedData.uuid, username: updatedData.username, bio: updatedData.bio, imageURL: updatedData.imageURL, isPublic: updatedData.isPublic,
                                          sports: updatedData.sports, clubs: updatedData.clubs, badges: updatedData.badges, trophies: updatedData.trophies, friends: updatedData.friends)
                }

            } catch {
                print(error)
                print("Could not get stored user data.")
            }
        }
    }
    
    func generateClubsData() async {
        if let clubs = user?.clubs {
            for club in clubs {
                let club = await self.clubObserver.getClub(id: club)
                if let c = club {
                    await MainActor.run(body: {
                        myClubs.append(c)
                    })
                }
            }
        }
    }
    
}
