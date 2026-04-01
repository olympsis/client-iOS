//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import os
import OSLog
import MapKit
import SwiftUI
import Foundation
import FirebaseAuth
import CoreLocation

/// App session data, fetched every session, stored in memory until app is closed
@Observable
class SessionStore {
    
    /// A global state variable for the whole app.
    /// If the user data isn't loaded in or we haven't completed the data loading, the whole app should be on a loading state together
    var state: LOADING_STATE = .loading
    
    var clubsState: LOADING_STATE = .pending
    
    var user: User?              // User data Cache
    
    var clubs: Set<Club> = []
    var orgs: Set<Organization> = []
    
    var events: Set<Event> = []
    var pastEvents: Set<Event> = []
    
    var tags: [Tag] = []
    var sports: [Sport] = []
    
    var venues = [Venue]()           // Venues Cache
    var hotEvents = [Event]()        // Hot Events Cache
    var invitations = [Invitation]() // Invitations Cache
    var notifications = [NotificationItem]()
    
    // Observers
    var authObserver = AuthObserver()
    var feedObserver = FeedObserver()
    var cacheService = CacheService()
    var userObserver = UserObserver()
    var clubObserver = ClubObserver()
    var orgObserver = OrgObserver()
    var postObserver = PostObserver()
    var fieldObserver = FieldObserver()
    var eventObserver = EventObserver()
    var workoutManager = WorkoutManager()
    var managementObserver = ManagementObserver()
    var notificationService = NotificationService()
    
    var groupsManager = GroupsManager()

    // This variable helps us keep track of the user's current location. It also includes a fallback to a location
    // This fallback location is a second location in case we are unable to find the user's current location
    // In this case we check to see if they have a stored location(hometown)
    // If not then we default to new york city
    var currentLocation: MKCoordinateRegion {
        guard let location = LocationManager.shared.location else {
            guard let user = user, let hometown = user.hometown else {
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988), latitudinalMeters: 5000, longitudinalMeters: 5000)
            }
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0]), latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
    
    /**
     App lifetime data
     Whenever set, this is cached in app until changed or app is removed
     */
    
    /// App mode to keep track on wether the user is paid/free
    @ObservationIgnored
    @AppStorage("app_mode") var appMode: APP_MODE = .free
    
    /// App state to keep track of normal/developer mode
    @ObservationIgnored
    @AppStorage("app_state") var appState: APP_STATE = .normal
    
    /// Keeps track of the user's search radius for venues and events
    @ObservationIgnored
    @AppStorage("searchRadius") var radius: Double?
    
    @ObservationIgnored
    @AppStorage("selected_group_id") var selectedGroupID: String?
    
    @ObservationIgnored
    @AppStorage("deviceToken") private var dToken: String?
    
    @ObservationIgnored
    @AppStorage("auth_type") private var authType: USER_STATUS?
    
    @ObservationIgnored
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?

    
    private let secureStore = SecureStore()
    private var isRegisterComplete: Bool {
        
        let user = cacheService.fetchUser()
        guard user?.username != nil,
              user?.sports != nil,
              user?.visibility != nil else {
            return false
        }
        return true
    }
    private var log = Logger(subsystem: "com.olympsis.client", category: "session_store")
    
    init() {
        authStatus = .unknown
        user = cacheService.fetchUser()
        
        Task {
            do {
                let config = try await managementObserver.config()
                tags = config.tags
                sports = config.sports
            } catch {
                #if !targetEnvironment(simulator)
                fatalError("Failed to fetch application config. Error: \(error)")
                #endif
            }
        }
    }
    
    func listenToAuthStateChanges() {
        #if DEV
        // In local development we skip Firebase auth entirely and treat the
        // hardcoded dev user as already authenticated. The actual user ID is
        // supplied via the DEV_USER_ID key in Info.plist (see AppEnvironment).
        // Check-in and notifications are handled by ViewContainer's .task block.
        self.authStatus = .authenticated
        #else
        Auth.auth().addStateDidChangeListener { [weak self] auth, usr in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if (usr != nil) {
                    guard self.authType != nil && self.authType == .new else {
                        guard self.isRegisterComplete else {
                            self.authStatus = .unauthenticated
                            return
                        }
                        // Avoid redundant write — re-setting .authenticated
                        // causes SwiftUI to recreate ViewContainer mid-checkIn
                        guard self.authStatus != .authenticated else { return }
                        self.authStatus = .authenticated
                        return
                    }
                    self.authStatus = .unauthenticated
                } else {
                    self.authStatus = .unauthenticated
                }
            }
        }
        #endif
    }
    
    func updateNotifications() async {
        do {
            guard try await NotificationManager.shared.checkAuthorizationStatus() else {
                log.error("Failed to get authorization status.")
                return
            }
            
            guard let dToken = dToken else {
                log.error("Failed to grab notification token from cache.")
                return
            }
            
            let uuid = await UIDevice.current.identifierForVendor?.uuidString
            let model = await UIDevice.current.model
            let device = NotificationDevice(
                deviceID: uuid,
                token: dToken,
                platform: .ios,
                model: model,
                active: true,
                createdAt: Date(),
                updatedAt: nil
            )
            
            // Check for existing devices
            guard let user = cacheService.fetchUser(),
                  var devices = user.notificationDevices else {
                let dao = UserDao(notificationDevices: [device])
                guard let user = await userObserver.UpdateUserData(update: dao) else {
                    log.error("Failed to update user with new device token.")
                    return
                }
                cacheService.cacheUser(user: user)
                self.user = user
                return
            }
            
            // Check for this device
            guard let idx = devices.firstIndex(where: { $0.deviceID == uuid }) else {
                devices.append(device)
                let dao = UserDao(notificationDevices: devices)
                guard let user = await userObserver.UpdateUserData(update: dao) else {
                    log.error("Failed to update user with new device token.")
                    return
                }
                cacheService.cacheUser(user: user)
                self.user = user
                return
            }
            
            // Make sure that it's not the same
            guard devices[idx].token != dToken else {
                return
            }
            
            devices[idx].token = dToken
            devices[idx].updatedAt = Date()
            let dao = UserDao(notificationDevices: devices)
            guard let user = await userObserver.UpdateUserData(update: dao) else {
                log.error("Failed to update user with new device token.")
                return
            }
            cacheService.cacheUser(user: user)
            self.user = user
        } catch {
            log.error("Failed to check authorization status: \(error.localizedDescription)")
            return
        }
    }
    
    func checkIn() async {
        
        clubs = []
        orgs = []
        
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
                c.forEach { c in
                    self.clubs.insert(c)
                    let group = GroupSelection(type: .Club, club: c, organization: nil, posts: nil)
                    groupsManager.add(group)
                }
            }
            if let o = resp.organizations {
                o.forEach { o in
                    self.orgs.insert(o)
                    let group = GroupSelection(type: .Organization, club: nil, organization: o, posts: nil)
                    groupsManager.add(group)
                }
            }
            if let i = resp.invitations {
                invitations = i
            }
            
            groupsManager.restore()
            authStatus = .authenticated
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            authStatus = .unauthenticated
            log.error("Failed to check user in: \(error.localizedDescription)")
        }
    }
    
    func getNotifications() async {
        self.notifications = []
//        do {
//            self.notifications = try await notificationService.GetNotifications().notifications
//        } catch {
//            log.error("Failed to get notifications. Error: \(error)")
//        }
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
            resp.venues?.forEach { self.venues.append($0) }
            resp.events?.forEach { self.events.insert($0) }
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
            if organizer.type == GROUP_TYPE.Club {
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
                if
                   let cod = desc.location,
                   let loc = await desc.geocode()?.first,
                   let city = loc.locality,
                   let state = loc.administrativeArea,
                   let country = loc.country {
                    fetchedVenues.append(
                        Venue(
                            name: desc.name ?? "Custom Venue",
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
        clubs.insert(club)
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
        self.orgs.insert(org)
        return org
    }
    
    /// Logout user from application
    /// - Clears cache from all data
    /// - Calls firebase API to sign out user
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
    /// - Makes a call to firebase servers to delete account.
    /// - Makes a call to Olympsis servers to delete account
    /// - Clears cache of all data
    /// - Returns: a boolean of wether or not we were successful in deleting the user's account
    func deleteAccount() async -> Bool {
        do {
            guard let user = Auth.auth().currentUser else { return false }
            let signInWithApple = await SignInWithApple()
            let appleIDCredential = try await signInWithApple()
            guard let appleIDToken = appleIDCredential.identityToken else {
                log.error("Unable to fetdch identify token.")
                return false
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                log.error("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                return false
            }
            
            let nonce = randomNonceString()
                    let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            try await user.reauthenticate(with: credential)
            
            guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
            guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }

            guard try await authObserver.deleteAccount() else { return false }
            
            try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            
            try await user.delete()

            authStatus = .unauthenticated
            
            // clear cached app data
            cacheService.clearCache()
            secureStore.clearKeyChain()
            
            return true
        } catch {
            log.error("Failed to delete user account: \(error)")
        }
        return false
    }
}
