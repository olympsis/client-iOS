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
    
    // MARK: - Foreground Toast

    /// Leading glyph for a lean event note.
    ///
    /// Mirrors the inbox rows on purpose — a reminder shows the same yellow
    /// clock whether it arrives as a toast now or is read on the notifications
    /// page later. These are symbols rather than the actor's avatar because
    /// resolving `actor_id` to a user would mean an async lookup, and this
    /// manager is a singleton with no session to do it through.
    private func glyph(for kind: EventPushNote.Kind) -> InAppNotificationImage {
        switch kind {
        case .participant:
            return .system("person.fill.badge.plus", tint: .accentColor)
        case .comment:
            return .system("bubble.left.fill", tint: .accentColor)
        case .reminder:
            return .system("clock.fill", tint: Color.Foreground.yellow)
        }
    }

    /// Builds the in-app card for a lean event note.
    ///
    /// Everything is read off the payload as it stands at `willPresent`, which
    /// is AFTER the notification service extension has run:
    ///
    /// - `content.title` is the event name. The server guarantees it is
    ///   non-empty (iOS drops a notification whose title is empty).
    /// - `content.body` is the string the extension localized from
    ///   `loc_key`/`loc_args`. The server deliberately sends no body of its own,
    ///   so if the extension was killed (30s budget / low memory) this is empty
    ///   — hence the `nil`, which renders a title-only card rather than a card
    ///   with a blank second line.
    /// - `event_image_url` is a RELATIVE storage path, as everywhere else in the
    ///   app, so it goes through `generateImageURL`. The card renders it with
    ///   the Kingfisher loader `ViewContainer` injects, sharing the app's cache.
    private func toast(for note: EventPushNote, from notification: UNNotification) -> InAppNotification {
        let content = notification.request.content

        var trailing: InAppNotificationImage = .none
        if let path = content.userInfo["event_image_url"] as? String,
           let url = generateImageURL(path) {
            trailing = .remote(url)
        }

        return InAppNotification(
            title: content.title,
            subtitle: content.body.isEmpty ? nil : content.body,
            leadingImage: glyph(for: note.kind),
            trailingImage: trailing,
            // Collapse a burst of the same kind for the same event into one
            // card, while still letting a comment and a reminder for that event
            // queue up separately.
            coalesceID: "\(note.kind.rawValue):\(note.eventID)",
            onTap: { [weak self] in
                guard let self, let url = self.deepLink(for: note) else { return }
                self.routeOrQueue(url)
            }
        )
    }

    // Called when a notification arrives while the app is in the foreground.
    //
    // The lean event notes (participant / comment / reminder) are presented as
    // an in-app toast through NotificationKit, whose host is mounted on
    // `ViewContainer`. Tapping the card deep-links into the event — the same
    // destination `didReceive` sends a tapped system notification to, so the
    // foreground and background paths agree.
    //
    // `.banner` is deliberately NOT requested: the toast already shows the
    // notification, and asking for both would stack Apple's banner on top of
    // it. Badge and sound still come from the system.
    //
    // Every other type presents nothing in the foreground — they have no in-app
    // representation yet.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let note = EventPushNote(from: notification) else {
            completionHandler([])
            return
        }

        let card = toast(for: note, from: notification)
        // The presenter is main-actor isolated; this callback carries no such
        // guarantee, so hop explicitly rather than relying on it.
        Task { @MainActor in
            InAppNotificationPresenter.shared.present(card)
        }

        completionHandler([.badge, .sound])
    }
}
