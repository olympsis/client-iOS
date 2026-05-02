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
            updatedAt: Date()
        )
        
        let dao = UserDao(notificationPreference: update)
        isUpdating = true
        guard let usr = await session.userObserver.updateUserData(update: dao) else {
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
                    Text(String(localized: "notifications-setting-title", table: "Settings"))
                }
                .padding(.horizontal)
                .onChange(of: isEnabled) { _, newValue in
                    guard isEnabled else { return }
                    Task {
                        await updateNotificationSettings()
                    }
                }

                Text(String(localized: "notifications-setting-sub-title", table: "Settings"))
                    .font(.caption)
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
                
                VStack(alignment: .leading) {
                    if (isEnabled) {
                        VStack(alignment: .leading) {
                            Toggle(isOn: $pushEnabled) {
                                Text(String(localized: "notifications-push-title", table: "Settings"))
                            }
                            .padding(.horizontal)
                            .onChange(of: pushEnabled) { _, newValue in
                                Task {
                                    if pushEnabled {
                                        await NotificationManager.shared.requestAuthorization()
                                        guard try await NotificationManager.shared.checkAuthorizationStatus() else {
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
                            
                            Text(String(localized: "notifications-push-sub-title", table: "Settings"))
                                .font(.caption)
                                .padding(.horizontal)
                                .foregroundStyle(.gray)
                        }.padding(.leading)
                        
                        VStack(alignment: .leading) {
                            Toggle(isOn: $emailEnabled) {
                                Text(String(localized: "notifications-email-title", table: "Settings"))
                            }
                            .padding(.horizontal)
                            .onChange(of: emailEnabled) { _, newValue in
                                Task {
                                    await updateNotificationSettings()
                                }
                            }
                            
                            Text(String(localized: "notifications-email-sub-title", table: "Settings"))
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
        .navigationTitle(String(localized: "notifications-title", table: "Settings"))
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
                let status = try await NotificationManager.shared.checkAuthorizationStatus()
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
