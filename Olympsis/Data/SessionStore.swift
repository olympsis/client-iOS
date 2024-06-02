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
import FirebaseAuth
import CoreLocation

/// App session data, fetched every session, stored in memory until app is closed
class SessionStore: ObservableObject {
    
    private let secureStore = SecureStore()
    private var log = Logger(subsystem: "com.olympsis.client", category: "session_store")
    
    /// Global variable to keep track of the first lcation recieved when the app is opened.
    /// We have to wait on the gps system to give us a location. Sometimes this may take longer than the startup sequence.
    /// So we load in data from a fall back location until we get the location from the gps module.
    @Published var locationRecieved: Bool = false {
        didSet {
            Task {
                guard let location = locationManager.location else {
                    return
                }
                await getNearbyData(location: location)
            }
        }
    }
    
    /// A global state variable for the whole app.
    /// If the user data isn't loaded in or we haven't completed the data loading, the whole app should be on a loading state together
    @Published var state: LOADING_STATE = .pending
    
    @Published var user: UserData?              // User data Cache
    @Published var clubs = [Club]()             // Clubs Cache
    @Published var orgs = [Organization]()      // Organizations Cache
    @Published var events = [Event]()           // Events Cache
    @Published var venues = [Venue]()           // Venues Cache
    @Published var hotEvents = [Event]()        // Hot Events Cache
    @Published var invitations = [Invitation]() // Invitations Cache
    
    @Published var clubsState: LOADING_STATE = .pending
    
    // groups & posts
    @Published var selectedGroup: GroupSelection?
    @Published var posts: [Post] = [Post]()
    @Published var cachedPosts: [UUID: [Post]] = [:]
    @Published var groups: [GroupSelection] = [GroupSelection]()
    
    // Observers
    @ObservedObject var authObserver = AuthObserver()
    @ObservedObject var feedObserver = FeedObserver()
    @ObservedObject var cacheService = CacheService()
    @ObservedObject var userObserver = UserObserver()
    @ObservedObject var clubObserver = ClubObserver()
    @ObservedObject var orgObserver = OrgObserver()
    @ObservedObject var postObserver = PostObserver()
    @ObservedObject var fieldObserver = FieldObserver()
    @ObservedObject var eventObserver = EventObserver()
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var notificationsManager = NotificationManager()
    
    /**
     App lifetime data
     Whenever set, this is cached in app until changed or app is removed
     */
    @AppStorage("searchRadius") var radius: Double? // search radius for fields/events in meters
    @AppStorage("auth_type") private var authType: USER_STATUS?
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    var isRegisterComplete: Bool {
        
        let user = cacheService.fetchUser()
        guard user?.username != nil,
              user?.sports != nil,
              user?.visibility != nil else {
            return false
        }
        return true
    }
    
    init() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = notificationsManager
        authStatus = .unknown
        user = cacheService.fetchUser()
        
        Auth.auth().addStateDidChangeListener { auth, usr in
            if (usr != nil) {
                guard self.authType != nil && self.authType == .new else {
                    guard self.isRegisterComplete else {
                        self.authStatus = .unauthenticated
                        return
                    }
                    self.authStatus = .authenticated
                    return
                }
                self.authStatus = .unauthenticated
            } else {
                self.authStatus = .unauthenticated
            }
        }
    }

    
    @MainActor
    func CheckIn() async {
        do {
            guard let resp = try await userObserver.CheckIn() else {
                return
            }
            if let usr = resp.user {
                _ = cacheService.fetchUser()
                user = usr
                cacheService.cacheUser(user: usr)
            } else {
                user = cacheService.fetchUser()
            }
            if let c = resp.clubs {
                self.clubs = c
                c.forEach { c in
                    let group = GroupSelection(type: .Club, club: c, organization: nil, posts: nil)
                    self.groups.append(group)
                }
                guard let g = self.groups.first else {
                    return
                }
                self.selectedGroup = g
            }
            if let o = resp.organizations {
                self.orgs = o
                o.forEach { o in
                    let group = GroupSelection(type: .Organization, club: nil, organization: o, posts: nil)
                    self.groups.append(group)
                }
                if (self.selectedGroup == nil) {
                    guard let g = self.groups.first else {
                        return
                    }
                    self.selectedGroup = g
                }
            }
            if let i = resp.invitations {
                invitations = i
            }
            authStatus = .authenticated
        } catch {
            authStatus = .unauthenticated
            log.error("Failed to check user in: \(error.localizedDescription)")
        }
    }
    
    func getNearbyData(location: CLLocationCoordinate2D, selectedSports: [String]?=nil) async {
        guard let user = self.user,
              var sports = user.sports else {
            return
        }
        
        // selected sports in map view
        if let sSports = selectedSports {
            sports = sSports
        }
        
        let sportsJoined = sports.joined(separator: ",")
        
        // convert radius to Int
        var radius: Int {
            guard let radius = self.radius else {
                return 17000
            }
            return Int(radius)
        }
        guard let resp = await self.eventObserver.location(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: radius,
            sports: sportsJoined) else {
            return
        }
        
        await MainActor.run {
            self.venues = resp.fields ?? [Venue]()
            self.events = resp.events ?? [Event]()
        }
    }
    
    func logout() async {
        cacheService.clearCache()
        
        do {
            try Auth.auth().signOut()
        } catch {
            log.error("Failed to sign user out: \(error.localizedDescription)")
            return
        }
        
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
            log.error("Failed to delete user account: \(error)")
        }
        return false
    }
}
