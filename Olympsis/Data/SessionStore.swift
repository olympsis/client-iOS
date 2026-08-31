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
@MainActor
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
    
    var venues = [Venue]()
    var hotEvents = [Event]()

    /// Pending invites from invite-service, seeded by check-in and refreshed by
    /// `refreshInvites()`.
    var invitations = [InviteResponse]()

    /// Organization invitations the user has *sent*, in the legacy `Invitation`
    /// shape. Separate from `invitations` above: different model, different
    /// direction, different backing service.
    var orgInvitations = [Invitation]()

    var announcements = [Announcement]()
    var notifications = [NotificationModel]()
    
    
    // Observers
    var authService = AuthService()
    var cacheService = CacheService()
    var userService = UserService()
    var clubService = ClubService()
    var orgService = OrgService()
    var postService = PostService()
    var venueService = VenueService()
    var eventService = EventService()
    var inviteService = InviteService()
    var workoutManager = WorkoutManager()
    var managementService = ManagementService()
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
    
    /// Number of unread notifications, for the bell badge.
    var unreadNotificationCount: Int {
        notifications.count { !$0.isRead }
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
                let config = try await managementService.config()
                tags = config.tags
                sports = config.sports
            } catch {
                self.authStatus = .fatal_error
            }
        }
    }
    
    func listenToAuthStateChanges() {
        #if DEV
        // In local development we skip Firebase auth entirely. The user is picked in
        // DevAuth and stored in DevUserStore; that ID is what gets sent as the UserID
        // header (see AppEnvironment). Until something has been picked we stay
        // unauthenticated so DevAuth gets a chance to show.
        // Check-in and notifications are handled by ViewContainer's .task block.
        self.authStatus = DevUserStore.selectedUserID != nil ? .authenticated : .unauthenticated
        #else
        Auth.auth().addStateDidChangeListener { [weak self] auth, usr in
            guard let self = self else { return }
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
            
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            let device = NotificationDevice(
                deviceID: uuid,
                token: dToken,
                // Nest under device_info to match the server schema — the old
                // flat platform/model keys were dropped on decode, which is why
                // device_info was stored empty.
                deviceInfo: DeviceInfo(
                    platform: "ios",
                    osVersion: UIDevice.current.systemVersion,
                    deviceModel: UIDevice.current.model
                ),
                active: true,
                createdAt: Date(),
                updatedAt: nil
            )
            
            // Check for existing devices
            guard let user = cacheService.fetchUser(),
                  var devices = user.notificationDevices else {
                let dao = UserDao(notificationDevices: [device])
                guard let user = await userService.updateUserData(update: dao) else {
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
                guard let user = await userService.updateUserData(update: dao) else {
                    log.error("Failed to update user with new device token.")
                    return
                }
                cacheService.cacheUser(user: user)
                self.user = user
                return
            }
            
            // Re-send only if the token OR the device info changed. The
            // device_info check also heals rows registered before the nested
            // device_info fix, whose stored info is empty — on the next call
            // it differs from the freshly built one, so we push the update.
            guard devices[idx].token != dToken || devices[idx].deviceInfo != device.deviceInfo else {
                return
            }

            devices[idx].token = dToken
            devices[idx].deviceInfo = device.deviceInfo
            devices[idx].updatedAt = Date()
            let dao = UserDao(notificationDevices: devices)
            guard let user = await userService.updateUserData(update: dao) else {
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
            guard let resp = try await userService.checkIn() else {
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
            #if DEBUG
            print(context)
            #endif
        } catch let DecodingError.keyNotFound(key, context) {
            #if DEBUG
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            #endif
        } catch let DecodingError.valueNotFound(value, context) {
            #if DEBUG
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            #endif
        } catch let DecodingError.typeMismatch(type, context)  {
            #if DEBUG
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            #endif
        } catch {
            authStatus = .unauthenticated
            log.error("Failed to check user in: \(error.localizedDescription)")
        }
    }
    
    func getNotifications() async {
        do {
            let notes = try await self.notificationService.GetNotifications()
            self.notifications = notes.notifications
        } catch {
            log.error("Failed to get notifications! Error: \(error.localizedDescription)")
        }
    }

    /// Marks notifications read server-side and locally.
    ///
    /// The local update is applied only after the server confirms, so a failed
    /// call leaves the badge honest rather than silently clearing it.
    @discardableResult
    func markNotificationsRead(_ ids: [String]) async -> Bool {
        guard !ids.isEmpty else {
            return false
        }
        do {
            let ok = try await notificationService.UpdateNotification(
                request: NotificationUpdateRequest(action: "read", notificationIDs: ids)
            )
            guard ok else { return false }
            for index in notifications.indices where ids.contains(notifications[index].id) {
                notifications[index].isRead = true
            }
            return true
        } catch {
            log.error("Failed to mark notifications read! Error: \(error.localizedDescription)")
            return false
        }
    }

    /// Archives notifications server-side and drops them from the inbox.
    ///
    /// Follows `markNotificationsRead` above: the local mutation only lands once
    /// the server confirms, so a failed archive leaves the row on screen rather
    /// than making it vanish and then reappear on the next fetch.
    ///
    /// The rows are removed outright instead of being flagged because
    /// `getNotifications()` requests the unarchived inbox — an archived row is
    /// never coming back in that list, so there's no local state to carry. The
    /// server keeps them (`is_archived = true`) and supports `unarchive`, so
    /// this stays recoverable even though the client currently offers no way
    /// back.
    @discardableResult
    func archiveNotifications(_ ids: [String]) async -> Bool {
        guard !ids.isEmpty else {
            return false
        }
        do {
            let ok = try await notificationService.UpdateNotification(
                request: NotificationUpdateRequest(action: "archive", notificationIDs: ids)
            )
            guard ok else { return false }
            notifications.removeAll { ids.contains($0.id) }
            return true
        } catch {
            log.error("Failed to archive notifications! Error: \(error.localizedDescription)")
            return false
        }
    }

    /// Fetches the caller's archived notifications.
    ///
    /// Returns the page instead of storing it. `notifications` is the live bell
    /// inbox, which `getNotifications()` deliberately fetches unarchived — so
    /// archived rows must not land in that array or they'd show up in the inbox
    /// and inflate the unread badge. The archive screen owns them for as long as
    /// it's on screen.
    func archivedNotifications() async -> [NotificationModel] {
        do {
            let notes = try await notificationService.GetNotifications(scope: .archived)
            return notes.notifications
        } catch {
            log.error("Failed to get archived notifications! Error: \(error.localizedDescription)")
            return []
        }
    }

    /// Re-fetches the user's pending invites.
    ///
    /// Check-in already embeds these on launch, so this is for refreshing
    /// afterwards — a pull-to-refresh, or after answering one elsewhere.
    func refreshInvites() async {
        guard let userID = user?.userID else {
            return
        }
        do {
            let resp = try await inviteService.getUserInvites(userID: userID, status: .pending)
            self.invitations = resp.invites
        } catch {
            log.error("Failed to refresh invites! Error: \(error.localizedDescription)")
        }
    }

    /// Resolves the user who triggered a notification, from its `actor_id`.
    ///
    /// Cosmetic — it only fills in the avatar and username on a notification row
    /// — so every failure path returns nil and lets the caller fall back to a
    /// generic sender rather than surfacing an error.
    func actor(id: String?) async -> User? {
        guard let id, !id.isEmpty else {
            return nil
        }
        do {
            return try await userService.getUserByUserID(userID: id)
        } catch {
            log.error("Failed to fetch notification actor \(id)! Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Resolves the invite a notification refers to.
    ///
    /// notif-service stamps `invite_id` into a note's routing data, so the id is
    /// the fast path — one lookup, no list scan. `fallbackContextID` covers notes
    /// written before that key existed, where all we have is the event/team id.
    ///
    /// - Returns: the invite, or nil if neither route finds a pending one.
    func invite(id: String?, fallbackContextID: String?) async -> InviteResponse? {
        if let id, !id.isEmpty {
            do {
                let invite = try await inviteService.getInvite(id: id)
                // An already-answered invite isn't actionable; treat it as absent
                // so the caller disables its buttons.
                return invite.status == .pending ? invite : nil
            } catch {
                log.error("Failed to fetch invite \(id)! Error: \(error.localizedDescription)")
            }
        }
        guard let fallbackContextID else {
            return nil
        }
        return await pendingInvite(forContext: fallbackContextID)
    }

    /// Finds the caller's pending invite for a given context (an event, team,
    /// club or org id).
    ///
    /// The fallback for notes that don't carry an `invite_id`. Hits the network
    /// rather than reading `invitations`: that array is check-in's snapshot from
    /// app launch and is used elsewhere, so a note rendered later shouldn't
    /// depend on how stale it is.
    ///
    /// - Returns: the matching PENDING invite, or nil if there isn't one.
    func pendingInvite(forContext contextID: String) async -> InviteResponse? {
        guard let userID = user?.userID else {
            return nil
        }
        do {
            let resp = try await inviteService.getUserInvites(userID: userID, status: .pending)
            return resp.invites.first { $0.contextID == contextID }
        } catch {
            log.error("Failed to fetch pending invite! Error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Accepts or declines an invite and drops it from the pending list.
    ///
    /// `response` is the RSVP the user picked when accepting an event invite. The
    /// server currently decodes but ignores it — RSVP is still a separate call to
    /// the events endpoint — so it's passed for forward compatibility only.
    ///
    /// A 409 (`.alreadyHandled`) means another device already answered this
    /// invite. That's not a failure from the user's point of view, so we treat it
    /// as success and still remove the row rather than leaving it stuck.
    ///
    /// - Returns: whether the invite was resolved.
    func answerInvite(_ invite: InviteResponse, status: InviteStatus, response: RSVPStatus? = nil) async -> Bool {
        do {
            _ = try await inviteService.updateInvite(
                id: invite.id,
                request: UpdateInviteRequest(status: status, response: response)
            )
            invitations.removeAll { $0.id == invite.id }
            return true
        } catch InviteServiceError.alreadyHandled {
            invitations.removeAll { $0.id == invite.id }
            return true
        } catch {
            log.error("Failed to answer invite! Error: \(error.localizedDescription)")
            return false
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
        guard let venue = await venueService.fetchVenue(id: id) else {
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
        guard let club = await clubService.getClub(id: id) else {
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
        guard let org = await orgService.getOrganization(id: id) else {
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

        #if DEV
        // There is no Firebase session in local development — the "session" is just
        // whichever dev user ID we put in the UserID header. Drop the selection so the
        // app lands back on DevAuth. Without this we'd fall through to the DEV_USER_ID
        // baked into Info.plist and silently sign straight back in as that user.
        DevUserStore.signOut()

        // clearCache() only wipes the on-disk copy; the in-memory one would otherwise
        // survive and briefly render the previous user's data on the next sign in.
        user = nil
        #else
        do {
            try Auth.auth().signOut()
        } catch {
            log.error("Failed to sign user out: \(error.localizedDescription)")
            return
        }
        #endif

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
            let signInWithApple = SignInWithApple()
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

            guard try await authService.deleteAccount() else { return false }
            
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
