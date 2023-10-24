//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import os
import OSLog
import SwiftUI
import Foundation
import CoreLocation

class SessionStore: ObservableObject {
    
    /**
     App session data, fetched every session
     Stored in memory until app is closed
     */
    let secureStore = SecureStore()
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "session_store")
    
    @Published var authStatus: AUTH_STATUS = .unknown
    
    @Published var user: UserData?       // User data
    @Published var clubs = [Club]()      // Clubs Cache
    @Published var events = [Event]()    // Events Cache
    @Published var fields = [Field]()    // Fields Cache
    
    var clubTokens = [String:String]()
    
    @ObservedObject var authObserver = AuthObserver()
    @ObservedObject var feedObserver = FeedObserver()
    @ObservedObject var cacheService = CacheService()
    @ObservedObject var userObserver = UserObserver()
    @ObservedObject var clubObserver = ClubObserver()
    @ObservedObject var postObserver = PostObserver()
    @ObservedObject var fieldObserver = FieldObserver()
    @ObservedObject var eventObserver = EventObserver()
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var notificationsManager = NotificationsManager()
    @ObservedObject var workoutManager = WorkoutManager()
    
    /**
     App lifetime data
     Whenever set, this is cached in app until changed or app is removed
     */
    @AppStorage("searchRadius") var radius: Double? // search radius for fields/events in meters
    
    init() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = notificationsManager
        self.user = cacheService.fetchUser()
        authObserver.checkAuthStatus { (auth) in
            DispatchQueue.main.async {
                self.authStatus = auth
            }
        }
    }
    
    func fetchUser() async {
        user = cacheService.fetchUser()
    }
    
    func fetchUserClubs() async {
        // check to see if user has clubs
        guard let u = user, let clubIDs = u.clubs else {
            return
        }
        let resp = await clubObserver.generateUserClubs(clubIDs: clubIDs)
        DispatchQueue.main.async {
            self.clubs = resp
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
            return
        } catch {
            log.error("generateUpdatedUserData error: \(error.localizedDescription)")
            return
        }
    }
    
    func getNearbyData(location: CLLocationCoordinate2D) async {
        guard let user = self.user,
              let sports = user.sports else {
            return
        }
        let sportsJoined = sports.joined(separator: ",")
        
        // convert radius to Int
        var radius: Int {
            guard let radius = self.radius else {
                return 17000
            }
            return Int(radius)
        }
        // fetch nearby fields
        let fieldsResp = await self.fieldObserver.fetchFields(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: radius,
            sports: sportsJoined);
        
        // if there are no fields in the area then there are no events
        guard fieldsResp != nil else {
            return
        }
        
        // fetch nearby events
        let eventsResp = await self.eventObserver.fetchEvents(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: radius,
            sports: sportsJoined);
        
        await MainActor.run {
            self.fields = fieldsResp ?? [Field]()
            self.events = eventsResp ?? [Event]()
        }
    }
    
    func getEvents() async {
        guard let user = self.user,
              let sports = user.sports else {
            return
        }
        let sportsJoined = sports.joined(separator: ",")
        
        // convert radius to Int
        var radius: Int {
            guard let radius = self.radius else {
                return 17000
            }
            return Int(radius)
        }
        
        // location
        guard let location = self.locationManager.location else {
            return
        }
        
        // fetch nearby events
        let eventsResp = await self.eventObserver.fetchEvents(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: radius,
            sports: sportsJoined);
        
        await MainActor.run {
            self.events = eventsResp ?? [Event]()
        }
    }
    
    func logout() async {
        // clear cached app data
        cacheService.clearCache()
        
        // clear secure store
        secureStore.clearKeyChain()
        
        // go back to login page
        authStatus = .unauthenticated
        return
    }
    
    func deleteAccount() async -> Bool {
        do {
            let resp = try await authObserver.deleteAccount()
            
            guard resp == true else {
                return false
            }
            // clear cached app data
            cacheService.clearCache()
            
            // clear secure store
            secureStore.clearKeyChain()
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
}
