//
//  Notifications.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import os
import SwiftUI

struct NotificationSettings: View {
    
    @State private var isEnabled: Bool = false
    @State private var notifications = NotificationManager()
    @Environment(\.dismiss) private var dismiss
    
    var logger: Logger = Logger(subsystem: "com.olympsis.client", category: "notification_settings_view")
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                Text("Notification Settings")
                    .font(.title2)
                    .bold()
                Spacer()
            }.padding(.all)
            
            Toggle(isOn: $isEnabled) {
                Text("Allow Notifications")
            }.padding(.horizontal)
                .disabled(true)
            Text("To disable notifications please visit your settings and find Olympsis and disable it there. This is tempoary.")
                .font(.caption)
                .padding(.horizontal)
                .foregroundStyle(.gray)
            Spacer()
        }.task {
            do {
                let status = try await notifications.checkAuthorizationStatus()
                isEnabled = status
            } catch {
                logger.error("\(error)")
            }
        }
    }
}

#Preview {
    NotificationSettings()
}
