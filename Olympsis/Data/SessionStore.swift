//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import os
import SwiftUI
import Foundation
import CoreLocation

class SessionStore: ObservableObject {
    
    /**
     App session data, fetched every session
     Stored in memory until app is closed
     */
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "session_store")
    
    @Published var user: UserData?       // user data
    @Published var fields = [Field]()    // Fields Cache
    @Published var clubs = [Club]()      // Clubs Cache
    @Published var events = [Event]()    // Events Cache
    @Published var posts = [Post]()      // Posts Cache
    @Published var myClubs = [Club]()    // Clubs Cache
    
    var clubTokens = [String:String]()
    
    @ObservedObject var cacheService = CacheService()
    @ObservedObject var userObserver = UserObserver()
    @ObservedObject var clubObserver = ClubObserver()
    @ObservedObject var fieldObserver = FieldObserver()
    @ObservedObject var eventObserver = EventObserver()
    
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var notificationsManager = NotificationsManager()
    
    /**
     App lifetime data
     Whenever set, this is cached in app until changed or app is removed
     */
    @AppStorage("loggedIn") var loggedIn: Bool? // makes sure the user is completely logged in
    @AppStorage("searchRadius") var radius: Double? // search radius for fields/events in meters
    
    
    
    init() {
        if let login = loggedIn {
            if login {
                user = cacheService.fetchUser()
            }
        }
    }
    
    func reInitObservers() {
        cacheService = CacheService()
        userObserver = UserObserver()
        clubObserver = ClubObserver()
        fieldObserver = FieldObserver()
        eventObserver = EventObserver()
    }
    
    /// This function fetches user data from the backend. It combines the two and stores it in the session.
    func generateUserData() async {
        do {
            reInitObservers()
            
            // fetch data from server
            let updatedData = try await userObserver.GetUserData()
            
            // fetch data from cache
            guard var cache = cacheService.fetchUser() else {
                return
            }
            cache.uuid = updatedData.uuid
            cache.username = updatedData.username
            cache.bio = updatedData.bio
            cache.imageURL = updatedData.imageURL
            cache.visibility = updatedData.visibility
            cache.clubs = updatedData.clubs
            cache.sports = updatedData.sports
            cache.deviceToken = updatedData.deviceToken
            
            // cache this new updated data
            cacheService.cacheUser(user: cache)
            
            // update session store
            await MainActor.run {
                self.user = cache
            }
        } catch {
            log.error("generateUpdatedUserData error: \(error.localizedDescription)")
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
    
    func fetchHomeViewData(location: CLLocationCoordinate2D) async {
        guard let user = self.user,
              let sports = user.sports else {
            return
        }
        
        let sportsJoined = sports.joined(separator: ",")
        
        // fetch nearby fields
        await self.fieldObserver.fetchFields(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: Int(self.radius ?? 17000), // meters
            sports: sportsJoined);
        
        // fetch nearby events
        await self.eventObserver.fetchEvents(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: Int(self.radius ?? 17000),
            sports: sportsJoined);
    }
    
}
