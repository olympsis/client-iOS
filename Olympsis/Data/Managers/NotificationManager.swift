//
//  NotificationsHandler.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import os
import SwiftUI
import Foundation
import NotificationCenter

@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()
    
    let center = UNUserNotificationCenter.current()
    
    var inMessageView: Bool = false

    @ObservationIgnored
    @AppStorage("deviceToken") private var dToken: String?
    
    // Navigation handler closure
    var navigationHandler: ((URL) -> Void)?

    // A deep link produced by a background notification tap before the
    // navigation handler was ready (e.g. a cold launch from the tap).
    // Flushed by `flushPendingNavigation()` once `ViewContainer` wires
    // up `navigationHandler`.
    private var pendingNavigationURL: URL?

    private var userObserver = UserObserver()
    private var cacheService = CacheService()
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "notification_manager")
    
    private override init() {
        super.init()
        center.delegate = self
    }
    
    // MARK: - Background Tap Navigation

    /// Builds an in-app deep link for a tapped lean event note. The `focus`
    /// query tells `EventView` where to scroll once it opens.
    ///
    /// - New Participant → open the event and scroll to the participants
    ///   section.
    /// - New Comment → open the event and scroll to the specific comment
    ///   (falls back to just the event if no comment id was sent).
    /// - Event Reminder → just open the event.
    private func deepLink(for note: EventPushNote) -> URL? {
        switch note.kind {
        case .participant:
            return URL(string: "olympsis://events?ID=\(note.eventID)&focus=participants")

        case .comment:
            guard let commentID = note.commentID else {
                return URL(string: "olympsis://events?ID=\(note.eventID)")
            }
            return URL(string: "olympsis://events?ID=\(note.eventID)&focus=comment&commentID=\(commentID)")

        case .reminder:
            return URL(string: "olympsis://events?ID=\(note.eventID)")
        }
    }

    /// Routes a deep link immediately if the app's navigation handler is
    /// ready, otherwise stashes it to be flushed once the handler
    /// registers. Dispatched to the main queue because navigation mutates
    /// the routers/UI.
    private func routeOrQueue(_ url: URL) {
        DispatchQueue.main.async {
            if let handler = self.navigationHandler {
                handler(url)
            } else {
                self.pendingNavigationURL = url
            }
        }
    }

    /// Called by `ViewContainer` right after it assigns `navigationHandler`.
    /// Flushes any deep link captured from a cold-launch notification tap.
    func flushPendingNavigation() {
        guard let url = pendingNavigationURL else { return }
        pendingNavigationURL = nil
        navigationHandler?(url)
    }

    // Request alert sound and badge notifications
    func requestAuthorization() async {
        do {
            await UIApplication.shared.registerForRemoteNotifications() // register for remote notifications
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert, .carPlay])
            
        } catch {
            log.error("Failed to request authorization: \(error.localizedDescription)")
        }
    }
    
    // checks and makes sure all the notification authorizations are there
    func checkAuthorizationStatus() async throws -> Bool {
        let status =  await center.notificationSettings()
        guard (status.authorizationStatus == .authorized) ||
                (status.authorizationStatus == .provisional) else { return false }
        return true
    }
    
    // checks to see if we can show alert notifications
    func checkAlertSetting() async throws -> Bool {
        let status = await center.notificationSettings()
        if status.alertSetting == .enabled {
            // alert-only notification even when device is unlocked
            return true
        }else{
            // notification with badge and sound and device locked
            return false
        }
    }
    
    // This method is called when the user interacts with a notification (taps on it).
    // You can use this method to handle actions associated with the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // The user tapped a system notification while the app was in the
        // background (or it was launched by the tap). If it's one of the
        // lean event notes, build a deep link and route to the right place
        // — navigating now if the app is ready, or queuing it for a cold
        // launch until `ViewContainer` registers the navigation handler.
        if let note = EventPushNote(from: response.notification),
           let url = deepLink(for: note) {
            routeOrQueue(url)
        }

        completionHandler()
    }
    
    // Called when a notification arrives while the app is in the
    // foreground. The rich in-app toast path is currently disabled; only
    // the lean event notes (participant / comment / reminder) opt into a
    // system banner so the user still sees them while using the app —
    // tapping that banner routes through `didReceive` to deep-link into the
    // event. All other types present nothing in the foreground until the
    // toast path is restored.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if EventPushNote(from: notification) != nil {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([])
        }
    }
}
