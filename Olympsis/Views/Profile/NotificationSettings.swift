//
//  Notifications.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import os
import SwiftUI

struct NotificationSettings: View {
    
    @State private var isUpdating = false
    
    @State private var isEnabled: Bool = false
    @State private var pushEnabled: Bool = false
    @State private var emailEnabled: Bool = false
    
    @State private var notifications = NotificationManager()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let logger: Logger = Logger(
        subsystem: "com.olympsis.client",
        category: "notification_settings_view"
    )
    
    func updateNotificationSettings() async {
        guard !isUpdating else { return }
        
        var types: [String: Bool] = [
            "push": false,
            "email": false
        ]
        
        if (pushEnabled) {
            types["push"] = true
        }
        
        if (emailEnabled) {
            types["email"] = true
        }
        
        let update = NotificationPreference(
            types: types,
            categories: [
                "groups": true,
                "events": true,
                "announcements": true
            ],
            updatedAt: Int64(Date().timeIntervalSince1970)
        )
        
        let dao = UserDao(notificationPreference: update)
        isUpdating = true
        guard let usr = await session.userObserver.UpdateUserData(update: dao) else {
            isUpdating = false
            return
        }
        
        isUpdating = false
        session.user = usr
        session.cacheService.cacheUser(user: usr)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Toggle(isOn: $isEnabled) {
                    Text("Allow Notifications")
                }
                .padding(.horizontal)
                .onChange(of: isEnabled) { _, newValue in
                    guard isEnabled else { return }
                    Task {
                        await updateNotificationSettings()
                    }
                }

                Text("Allow Olympsis to keep you up to date on what's happening in your community. This includes event updates, club notifications, and more.")
                    .font(.caption)
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
                
                VStack(alignment: .leading) {
                    if (isEnabled) {
                        VStack(alignment: .leading) {
                            Toggle(isOn: $pushEnabled) {
                                Text("Push Notifications")
                            }
                            .padding(.horizontal)
                            .onChange(of: pushEnabled) { _, newValue in
                                Task {
                                    if pushEnabled {
                                        await notifications.requestAuthorization()
                                        guard try await notifications.checkAuthorizationStatus() else {
                                            await updateNotificationSettings()
                                            return
                                        }
                                        pushEnabled = true
                                        emailEnabled = true
                                        if !isUpdating {
                                            await session.updateNotifications()
                                        }
                                    }
                                    await updateNotificationSettings()
                                }
                            }
                            
                            Text("Allow Olympsis to send you push notifications to this device, like event updates and club notifications")
                                .font(.caption)
                                .padding(.horizontal)
                                .foregroundStyle(.gray)
                        }.padding(.leading)
                        
                        VStack(alignment: .leading) {
                            Toggle(isOn: $emailEnabled) {
                                Text("Email Notifications")
                            }
                            .padding(.horizontal)
                            .onChange(of: emailEnabled) { _, newValue in
                                Task {
                                    await updateNotificationSettings()
                                }
                            }
                            
                            Text("Allow Olympsis to send you email notifications of special announcements and other important updates")
                                .font(.caption)
                                .padding(.horizontal)
                                .foregroundStyle(.gray)
                        }.padding(.leading)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Notifications")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .task {
            do {
                isUpdating = true
                let status = try await notifications.checkAuthorizationStatus()
                isEnabled = status
                
                if (isEnabled) {
                    guard let user = session.user,
                          let preferences = user.notificationPreference else {
                        pushEnabled = false
                        emailEnabled = false
                        return
                    }
                    
                    pushEnabled = preferences.types.contains(where: {$0.key == "push"});
                    emailEnabled = preferences.types.contains(where: {$0.key == "email"});
                    isUpdating = false
                }
            } catch {
                isUpdating = false
                logger.error("Failed to init notification settings: \(error)")
            }
        }
    }
}

#Preview {
    NotificationSettings()
        .environment(SessionStore())
}
