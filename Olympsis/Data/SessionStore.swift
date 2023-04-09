//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import SwiftUI
import Foundation

class SessionStore: ObservableObject {
    
    // this might be removed later on
    private var firstName: String?
    private var lastName: String?
    private var email: String?
    private var uuid: String?
    
    @Published var user: UserStore? // user data
    
    @Published var fields = [Field]()    // Fields Cache
    @Published var clubs = [Club]()      // Clubs Cache
    @Published var events = [Event]()    // Events Cache
    @Published var posts = [Post]()      // Posts Cache
    @Published var myClubs = [Club]()
    
    
    let cacheService: CacheService
    let userObserver: UserObserver
    let clubObserver: ClubObserver
    
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var notificationsManager: NotificationsManager
    
    @AppStorage("authToken") var authToken: String?
    @AppStorage("loggedIn") private var loggedIn: Bool? // makes sure the user is completely logged in
    @AppStorage("searchRadius") var radius: Double? // search radius for fields in miles
    
    init() {
        cacheService = CacheService()
        userObserver = UserObserver()
        clubObserver = ClubObserver()
        
        locationManager = LocationManager()
        notificationsManager = NotificationsManager()
        
        fetchIdentifiableDataFromCache()
        
        if let login = loggedIn {
            if login {
                user = cacheService.fetchUser()
            }
        }
    }
    
    func fetchIdentifiableDataFromCache() {
        (firstName, lastName, email) = cacheService.fetchIdentifiableData()
    }
    
    func getFirstName() -> String {
        return firstName ?? "unnamed";
    }
    
    func getLastName() -> String {
        return lastName ?? "user";
    }
    
    /// This function fetches user data from the backend. It combines the two and stores it in the session.
    func GenerateUpdatedUserData() async {
        do {
            // fetch data from server
            let updatedData = try await userObserver.GetUserData()
            (firstName, lastName, email) = cacheService.fetchIdentifiableData()
            let newUser = UserStore(firstName: firstName!, lastName: lastName!, email: email!,
                                    uuid: updatedData.uuid, username: updatedData.username, bio: updatedData.bio, imageURL: updatedData.imageURL, visibility: updatedData.visibility,
                                    sports: updatedData.sports, clubs: updatedData.clubs, badges: updatedData.badges, trophies: updatedData.trophies, friends: updatedData.friends)
            // update session store
            await MainActor.run {
                self.user = newUser
            }
            // cache user data
            await cacheService.cacheUser(user: newUser)
        } catch {
            print("GenerateUpdatedUserData Error:" + error.localizedDescription)
        }
    }
    
    func GenerateUserDataFirstTime(username: String, sports:[String]) async {
        (firstName, lastName, email) = cacheService.fetchIdentifiableData()
        
        let newUser = UserStore(firstName: firstName!, lastName: lastName!, email: email!, uuid: "", username: username, bio: "", visibility: "private", sports: sports)
        await MainActor.run {
            self.user = newUser
        }
        await cacheService.cacheUser(user: newUser)
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
