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

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    let center = UNUserNotificationCenter.current()
    
    @Published var showToast: Bool = false
    @Published var inMessageView: Bool = false
    @Published var toastPosition: DisplayPosition = .bottom
    @Published var toastContent: ToastContent = ToastContent(view: { AnyView(EmptyView()) })
    
    @AppStorage("deviceToken") private var dToken: String?
    
    private var userObserver = UserObserver()
    private var cacheService = CacheService()
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "notification_manager")
    
    override init() {
        super.init()
        center.delegate = self
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
                (status.authorizationStatus == .provisional) ||
                (status.authorizationStatus == .denied) else { return false }
        return true
    }
    
    // checks to see if we can show alert notifications
    func checkAlertSetting() async throws -> Bool {
        let status = await center.notificationSettings()
        if status.alertSetting == .enabled{
            // alert-only notification even when device is unlocked
            return true
        }else{
            // notification with badge and sound and device locked
            return false
        }
    }
    
    // Sets a local notification to remind users to head to the event
    func setEventLocalNotification(_ event: Event, minutesBefore: Int = 30) async {
        do {
            guard try await checkAuthorizationStatus() else { return }
            
            let subtitles = [
                "Time to make your way to the venue. ",
                "Get ready—the event kicks off shortly!",
                "The countdown is almost over—see you there!",
                "Don’t be late! Head to the event now.",
                "It’s almost game time—make your way over!",
                "The action begins soon—get moving!",
                "Your event is about to start—let’s go!",
                "Final call—time to head out!",
                "The excitement is about to begin!",
                "See you soon—the event starts shortly!"
            ]
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "\(event.title) is starting soon!"
            content.body = subtitles.randomElement() ?? "Get ready—the event starts soon!"
            content.sound = UNNotificationSound.default
            
            // Calculate the time 'minutesBefore' minutes before the specified date
            let earlyReminderTime = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: Date(timeIntervalSince1970: TimeInterval(event.startTime)))!
            
            // Extract date components from the early reminder time
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: earlyReminderTime)
            
            // Create trigger with the date components
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Create request with a unique identifier
            let identifier = event.id
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            try await center.add(request)
        } catch {
            log.error("Error scheduling local notification: \(error)")
        }
    }
    
    // Removes the local notification
    func removeEventLocalNotification(_ id: String) async {
        do {
            guard try await checkAuthorizationStatus() else { return }
            // Remove the specific notification with the given identifier
            center.removePendingNotificationRequests(withIdentifiers: [id])
        } catch {
            log.error("Error removing local notification: \(error)")
        }
    }
    
    // This method is called when the user interacts with a notification (taps on it).
    // You can use this method to handle actions associated with the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the user's response to the notification.
        // For example, you might want to open a specific screen in the app based on the notification's data.
        // Call the completion handler when you're done processing the notification.
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if (UIApplication.shared.applicationState == .inactive || UIApplication.shared.applicationState == .background) {
            completionHandler([[.banner, .badge, .sound]])
        } else {
            completionHandler([.sound])
            // Handle Notifications in App
//            let userInfo = notification.request.content.userInfo
//            let note = Notification(name: Notification.Name(rawValue: "toast-system"), userInfo: userInfo)
//            ToastManager.shared.sendNotification(note: note)
        }
    }
}
