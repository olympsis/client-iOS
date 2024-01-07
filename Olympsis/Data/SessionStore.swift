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

/// App session data, fetched every session, stored in memory until app is closed
class SessionStore: ObservableObject {
    
    private let secureStore = SecureStore()
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "session_store")
    
    @Published var authStatus: AUTH_STATUS = .unknown
    
    @Published var user: UserData?              // User data Cache
    @Published var clubs = [Club]()             // Clubs Cache
    @Published var orgs = [Organization]()      // Organizations Cache
    @Published var events = [Event]()           // Events Cache
    @Published var fields = [Field]()           // Fields Cache
    @Published var invitations = [Invitation]() // Invitations Cache
    
    @Published var clubsState: LOADING_STATE = .loading
    var clubTokens = [String:String]()
    
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
    
    func CheckIn() async {
        do {
            guard let resp = try await userObserver.CheckIn() else {
                authStatus = .unauthenticated
                return
            }
            await MainActor.run {
                if let usr = resp.user {
                    user = usr
                    cacheService.cacheUser(user: usr)
                } else {
                    user = cacheService.fetchUser()
                }
                if let c = resp.clubs {
                    self.clubs = c
                    c.forEach { c in
                        let group = GroupSelection(type: "club", club: c, organization: nil, posts: nil)
                        self.groups.append(group)
                    }
                    self.clubsState = .success
                    guard let g = self.groups.first else {
                        return
                    }
                    self.selectedGroup = g
                } else {
                    self.clubsState = .pending
                }
                if let o = resp.organizations {
                    self.orgs = o
                    o.forEach { o in
                        let group = GroupSelection(type: "organization", club: nil, organization: o, posts: nil)
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
                if let t = resp.token {
                    secureStore.saveTokenToKeyChain(token: t)
                }
                authStatus = .authenticated
            }
        } catch {
            authStatus = .unauthenticated
        }
    }
    
    func reInitObservers() {
        cacheService = CacheService()
        userObserver = UserObserver()
        clubObserver = ClubObserver()
        fieldObserver = FieldObserver()
        eventObserver = EventObserver()
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
            self.fields = resp.fields ?? [Field]()
            self.events = resp.events ?? [Event]()
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
