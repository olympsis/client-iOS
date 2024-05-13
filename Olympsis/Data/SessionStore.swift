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
    
    @Published var user: UserData?              // User data Cache
    @Published var clubs = [Club]()             // Clubs Cache
    @Published var orgs = [Organization]()      // Organizations Cache
    @Published var events = [Event]()           // Events Cache
    @Published var fields = [Field]()           // Fields Cache
    @Published var hotEvents = [Event]()        // Hot Events Cache
    @Published var invitations = [Invitation]() // Invitations Cache
    
    @Published var clubsState: LOADING_STATE = .loading
    
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

    
    
    func CheckIn() async {
        do {
            guard let resp = try await userObserver.CheckIn() else {
                return
            }
            await MainActor.run {
                if var usr = resp.user {
                    let temp = cacheService.fetchUser()
                    user = usr
                    usr.hometown = temp?.hometown
                    user?.hometown = temp?.hometown
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
            }
        } catch {
            authStatus = .unauthenticated
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
            self.fields = resp.fields ?? [Field]()
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
