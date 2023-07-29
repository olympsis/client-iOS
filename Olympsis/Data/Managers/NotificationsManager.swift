//
//  NotificationsHandler.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import Foundation
import SwiftToast
import NotificationCenter

class NotificationsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    let center = UNUserNotificationCenter.current()
    
    @Published var showToast: Bool = false
    @Published var toastContent: Toast = Toast(style: .newEvent, actor: "", title: "", message: "")
    
    @Published var inMessageView: Bool = false
    
    // Request alert sound and badge notifications
    func requestAuthorization() async throws {
        await UIApplication.shared.registerForRemoteNotifications() // register for remote notifications
        _ = try await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert, .carPlay]) // 
    }
    
    // checks and makes sure all the notification authorizations are there
    func checkAuthorizationStatus() async throws -> Bool {
        let status =  await center.notificationSettings()
        
        guard (status.authorizationStatus == .authorized) || (status.authorizationStatus == .provisional) else { return false }

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
        // Handle the notification when the app is in the foreground.
        // You can customize the behavior here, like showing an alert or playing a sound.
        
        // By default, no visual or audible alert is shown to the user for the notification.
        // You can change this behavior by specifying appropriate options in the completionHandler.
        
        let userInfo = notification.request.content.userInfo
        guard let type = userInfo["type"] as? String else {
            return
        }
        switch type {
        case ToastStyle.newEvent.rawValue:
            guard let title = userInfo["title"] as? String,
                  let actor = userInfo["actor"] as? String,
                  let message = userInfo["message"] as? String else {
                return
            }
            self.toastContent = Toast(style: ToastStyle.newEvent, actor: actor, title: title, message: message)
            self.showToast = true
            
        case ToastStyle.newPost.rawValue:
            guard let title = userInfo["title"] as? String,
                  let actor = userInfo["actor"] as? String,
                  let message = userInfo["message"] as? String else {
                return
            }
            self.toastContent = Toast(style: ToastStyle.newPost, actor: actor, title: title, message: message)
            self.showToast = true
            
        case ToastStyle.message.rawValue:
            guard !inMessageView else { // dont want to show toasts if you are in a message view
                break
            }
            guard let title = userInfo["title"] as? String,
                  let actor = userInfo["actor"] as? String,
                  let message = userInfo["message"] as? String else {
                return
            }
            self.toastContent = Toast(style: ToastStyle.message, actor: actor, title: title, message: message)
            self.showToast = true
            
        case ToastStyle.eventStatus.rawValue:
            guard let title = userInfo["title"] as? String,
                  let message = userInfo["message"] as? String else {
                return
            }
            self.toastContent = Toast(style: ToastStyle.newEvent, title: title, message: message)
            self.showToast = true
        default:
            break
        }
        if (UIApplication.shared.applicationState == .inactive || UIApplication.shared.applicationState == .background) {
            completionHandler([[.banner, .badge, .sound]])
        } else {
            completionHandler([.sound])
        }
        
    }
        

}
