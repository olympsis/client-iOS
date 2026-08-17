//
//  NotificationsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import os
import SwiftUI

struct NotificationsView: View {
    
    @State private var notifications: [NotificationModel] = []
    
    @Environment(HomeRouter.self) private var router
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "notifications_view")
    
    var body: some View {
        ScrollView {
            if session.notifications.count > 0 {
                ForEach(session.notifications, id: \.id){ note in
                    LazyVStack {
                        NotificationModelView(notification: note)
                            .environment(session)
                    }
                }
            } else {
                VStack {
                    Text("Olympsis Notifications will live here.")
                    HStack {
                        Spacer()
                    }
                }.padding(.top, 50)
            }
        }
        .background(Color.Background.primary.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action:{ router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.Foreground.default)
                }
                .id(UUID())
            }
            
            ToolbarItem(placement: .principal) {
                Text("Notifications")
            }
        }
        .toolbarRole(.navigationStack)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        router.navigateBack()
                    }
                }
        )
        .task {
            do {
                guard try await !NotificationManager.shared.checkAuthorizationStatus() else {
                    return
                }
                await NotificationManager.shared.requestAuthorization()
                await session.updateNotifications()
            } catch {
                log.error("Failed to determine or request notifications authorization. Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environment(HomeRouter())
            .environment(SessionStore())
    }
}
