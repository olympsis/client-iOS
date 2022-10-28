//
//  NotificationsHandler.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import Foundation
import NotificationCenter

class NotificationsHandler: ObservableObject{
    let center = UNUserNotificationCenter.current()
    
    init(){
        
    }
    
    // Request alert sound and badge notifications
    func requestAuthorization() async throws {
        _ = try await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert, .carPlay])
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
    
    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
    }
}
