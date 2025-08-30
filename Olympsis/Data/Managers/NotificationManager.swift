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
    
    var isShowing: Bool = false
    var inMessageView: Bool = false
    
    // Notification Queue
    var queue: [NotificationMetadata] = []
    var currentNotification: NotificationMetadata?
    private var dismissTask: Task<Void, Never>?
    
    // Track processed notifications to prevent duplicates
    private var processedNotifications = Set<String>()
    private var lastCleanupTime = Date()
    
    @ObservationIgnored
    @AppStorage("deviceToken") private var dToken: String?
    
    // Navigation handler closure
    var navigationHandler: ((URL) -> Void)?
    
    private var userObserver = UserObserver()
    private var cacheService = CacheService()
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "notification_manager")
    
    private override init() {
        super.init()
        center.delegate = self
    }
    
    // Handles inserting new note and triggering queue processing
    func show(_ notification: NotificationMetadata) {
        queue.append(notification)
        
        if currentNotification == nil {
            processQueue()
        }
    }
    
    // Process our notiication queue
    private func processQueue() {
        guard !queue.isEmpty else {
            currentNotification = nil
            isShowing = false
            return
        }
        
        let notification = queue.removeFirst()
        currentNotification = notification
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isShowing = true
        }
        
        // Auto-dismiss after 3 seconds (adjustable)
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            
            if !Task.isCancelled {
                dismiss()
            }
        }
    }
    
    // Handle in-app notification dismissal
    func dismiss() {
        dismissTask?.cancel()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isShowing = false
        }
        
        // Process next in queue after animation
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            processQueue()
        }
    }
    
    // Handle in-app notification interaction here
    func handleTap() {
        
        // Event Navigation
        if let eventID = currentNotification?.eventID,
            let url = URL(string: "olympsis://events?ID=\(eventID)") {
            dismiss()
            navigationHandler?(url)
            return
        }
        
        // Groups Navigation
        if let groupID = currentNotification?.groupID,
           let url = URL(string: "olympsis://groups?ID=\(groupID)") {
            dismiss()
            navigationHandler?(url)
            return
        }
        
        // Post Navigation
        if let groupID = currentNotification?.groupID,
           let postID = currentNotification?.postID,
           let url = URL(string: "olympsis://posts?ID=\(postID)&?groupID=\(groupID)") {
            dismiss()
            navigationHandler?(url)
            return
        }
        
        dismiss()
    }
    
    // Clean up old notification IDs to prevent memory leaks
    private func cleanupOldNotifications() {
        let now = Date()
        let fiveMinutesAgo = now.timeIntervalSince(lastCleanupTime)
        
        // Only cleanup every 5 minutes to avoid excessive processing
        if fiveMinutesAgo > 300 {
            processedNotifications.removeAll()
            lastCleanupTime = now
        }
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
    
    // This method is called for handling notiications when the app is opened
    // We will have our own toast system to show notifications internally
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationId = notification.request.identifier
        
        // Check for duplicate notification
        if processedNotifications.contains(notificationId) {
            completionHandler([])
            return
        }
        
        // Clean up old notification IDs (older than 5 minutes)
        cleanupOldNotifications()
        
        // Mark as processed
        processedNotifications.insert(notificationId)
        
        if (UIApplication.shared.applicationState == .inactive || UIApplication.shared.applicationState == .background) {
            completionHandler([[.banner, .badge, .sound]])
        } else {
            do {
                // Grab notification data
                guard let data = try NotificationMetadata(from: notification) else {
                    log.error("❌ Failed to create NotificationMetadata")
                    return
                }
                
                if data.type == .clubApplicationUpdate {
                    var notificationData: [String: Any] = ["type": "club"]
                    guard let groupID = data.groupID else {
                        return
                    }
                    notificationData["group_id"] = groupID
                    NotificationCenter.default.post(name: .groupAddedServerSide, object: nil, userInfo: notificationData)
                }
                
                completionHandler([.sound])
                show(data)
            } catch {
                log.error("Failed to parse notification data. Error: \(error.localizedDescription)")
                completionHandler([])
                return
            }
        }
    }
}
