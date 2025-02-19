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
        
        let userInfo = notification.request.content.userInfo
        let note = Notification(name: Notification.Name(rawValue: "toast-system"), userInfo: userInfo)
        ToastManager.shared.sendNotification(note: note)
        
        if (UIApplication.shared.applicationState == .inactive || UIApplication.shared.applicationState == .background) {
            completionHandler([[.banner, .badge, .sound]])
        } else {
            completionHandler([.sound])
        }
    }
}
