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
    @AppStorage("deviceToken") private var _token: String?
    @AppStorage("auth_type") private var authType: USER_STATUS?
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    private var isRegisterComplete: Bool {
        
        let user = cacheService.fetchUser()
        guard user?.username != nil,
              user?.sports != nil,
              user?.visibility != nil else {
            return false
        }
        return true
    }
    private let secureStore = SecureStore()
    private var log = Logger(subsystem: "com.olympsis.client", category: "session_store")
    
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
    
    func updateNotifications() async {
        await notificationsManager.requestAuthorization()
        guard let user = self.user,
              let token = _token,
              var tokens = user.deviceTokens else {
                  return
        }
        tokens.append(token)
        _ = await userObserver.UpdateUserData(update: UserDao(deviceTokens: tokens))
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
            self.venues = resp.venues ?? [Venue]()
            self.events = resp.events ?? [Event]()
        }
    }
    
    /// We want to dynamically fetch the clubs and organizations for each event
    ///
    /// We will fetch the data as needed. If we have it in local storage we fetch it form there.
    /// If we don't have it in local storage we fetch it remotely.
    /// - Parameter organizers: the event's organizers
    /// - Returns: an array of clubs and an array of organizations
    func fetchOrganizers(in organizers: [Organizer]) async -> ([Club], [Organization]) {
        var clubs = [Club]()
        var orgs = [Organization]()
        
        for organizer in organizers {
            if organizer.type == "club" {
                if let club = await fetchClub(id: organizer.id) {
                    clubs.append(club)
                }
            } else {
                if let org = await fetchOrg(id: organizer.id) {
                    orgs.append(org)
                }
            }
        }
        
        return (clubs, orgs)
    }
    
    /// We want to dynamically fetch the venue information to reduce the amount of data we're holding in memory
    ///
    /// We try to fetch the venue locally in memory if we have it stored and if it's an Olympsis vetted location.
    /// If we do not have the venue in memory we will try to fetch it remotely.
    /// If that fails then we will have to display an error.
    ///
    /// If the venue is not Olympsis vetted we will simply just open maps at the provided coordinates
    func fetchVenues(in descriptors: [VenueDescriptor]) async -> [Venue] {
        var fetchedVenues: [Venue] = []
        
        for desc in descriptors {
            if let id = desc.id {
                if let venue = await fetchVenueLocal(id: id) {
                    fetchedVenues.append(venue)
                } else {
                    if let venue = await fetchVenueRemote(id: id) {
                        fetchedVenues.append(venue)
                    }
                }
            } else {
                // External Venue
                if let name = desc.name,
                   let cod = desc.location,
                   let loc = await desc.geocode()?.first,
                   let city = loc.locality,
                   let state = loc.administrativeArea,
                   let country = loc.country {
                    fetchedVenues.append(
                        Venue(
                            name: name,
                            location: cod,
                            city: city,
                            state: state,
                            country: country
                        )
                    )
                }
            }
        }
        
        return fetchedVenues
    }
    
    /// Fetches the venue
    ///
    /// Wether the venue is held locally in memory or remotely on the server we try to fetch it
    /// - Parameter id: unique identifier for the venue
    /// - Returns an `Venue` optional
    func fetchVenue(id: String) async -> Venue? {
        guard let venue = await fetchVenueLocal(id: id) else {
            guard let venue = await fetchVenueRemote(id: id) else {
                return nil
            }
            return venue
        }
        return venue
    }
    
    /// Fetch the venue from the data we have in memory
    ///
    /// Tries to fetch club from session store memory
    /// - Parameter id: unique identifier for the venue
    /// - Returns: a `Venue` optional object in case we failt to find venue
    func fetchVenueLocal(id: String) async -> Venue? {
        guard let venue = venues.first(where: { $0.id == id }) else {
            log.error("Failed to find venue locally")
            return nil
        }
        return venue
    }
    
    /// Fetch the venue from the server
    ///
    /// Makes an http call to retrieve venue from the server
    /// - Parameter id: unique identifier for the venue
    /// - Returns: a `Venue` optinal object in case the server fails to find venue
    func fetchVenueRemote(id: String) async -> Venue? {
        guard let venue = await fieldObserver.fetchVenue(id: id) else {
            log.error("Failed to fetch venue data remotely")
            return nil
        }
        venues.append(venue)
        return venue
    }
    
    /// Fetches the club
    ///
    /// Wether the club is held locally in memory or remotely on the server we try to fetch it
    /// - Parameter id: unique identifier for the club
    /// - Returns an `Club` optional
    func fetchClub(id: String) async -> Club? {
        guard let club = await fetchClubLocal(id: id) else {
            guard let club = await fetchClubRemote(id: id) else {
                return nil
            }
            return club
        }
        return club
    }
    
    /// Fetch the club from the data we have in memory
    ///
    /// Tries to fetch club from session store memory
    /// - Parameter id: unique identifier for the club
    /// - Returns: a `Club` optional object in case the server fails to find club
    func fetchClubLocal(id: String) async -> Club? {
        guard let club = clubs.first(where: { $0.id == id }) else {
            log.error("Failed to find club locally")
            return nil
        }
        return club
    }
    
    /// Fetch the club from the server
    ///
    /// Makes an http call to retrieve club from the server
    /// - Parameter id: unique identifier for the club
    /// - Returns: a `Club` optinal object in case the server fails to find the org
    func fetchClubRemote(id: String) async -> Club? {
        guard let club = await clubObserver.getClub(id: id) else {
            log.error("Failed to find club data remotely")
            return nil
        }
        return club
    }
    
    /// Fetches the organization
    ///
    /// Wether the organization is held locally in memory or remotely on the server we try to fetch it
    /// - Parameter id: unique identifier for the organization
    /// - Returns an `Organization` optional
    func fetchOrg(id: String) async -> Organization? {
        guard let org = await fetchOrgLocal(id: id) else {
            guard let org = await fetchOrgRemote(id: id) else {
                return nil
            }
            return org
        }
        return org
    }
    
    /// Fetch the venue from the data we have in memory
    ///
    /// Tries to fetch venue from the session store memory
    /// - Parameter id: unique identifier for the organization
    /// - Returns: an `Organization` optional object in case the server fails to find the org
    func fetchOrgLocal(id: String) async -> Organization? {
        guard let org = orgs.first(where: { $0.id == id }) else {
            log.error("Failed to find organization locally")
            return nil
        }
        return org
    }
    
    /// Fetch the organization from the server
    ///
    /// Makes http call to retrieve organization from the server
    /// - Parameter id: unique identifier for the organization
    /// - Returns: an`Organization` optinal object in case the server fails to find the org
    func fetchOrgRemote(id: String) async -> Organization? {
        guard let org = await orgObserver.getOrganization(id: id) else {
            log.error("Failed to find organization data remotely")
            return nil
        }
        return org
    }
    
    /// Logout user from application
    ///
    /// Clears cache from all data
    ///
    /// Calls firebase API to sign out user
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
    
    /// Deletes the user's account from application
    ///
    /// Makes a call to firebase servers to delete account.
    ///
    /// Makes a call to Olympsis servers to delete account
    ///
    /// Clears cache of all data
    func deleteAccount() async -> Bool {
        do {
            try await Auth.auth().currentUser?.delete()
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
