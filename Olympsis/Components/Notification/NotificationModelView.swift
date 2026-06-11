//
//  NotificationView.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import SwiftUI

struct NotificationModelView: View {
    
    @State var notification: NotificationItem
    @Environment(SessionStore.self) private var session
    
    func modifyNotification(action: String) {
        Task {
            guard try await session.notificationService.UpdateNotification(
                request: NotificationUpdateRequest(
                    action: action,
                    notificationIDs: [notification.id])
            ) else {
                return
            }
            
            if action == "archive" {
                session.notifications.removeAll(where: { $0.id == notification.id })
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 55)
                .padding(.horizontal, 10)
                .foregroundStyle(Color.Background.secondary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(notification.title)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Foreground.default)
                    Text(notification.body)
                        .font(.caption)
                        .foregroundStyle(Color.Foreground.default)
                }
                
                Spacer()
                
                Menu {
                    Button(action:{ modifyNotification(action: "archive") }){
                        Label("Archive", systemImage: "archivebox")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            .padding(.horizontal, 25)
            
            if !notification.isRead {
                HStack {
                    Spacer()
                    
                    VStack {
                        Circle()
                            .foregroundStyle(.red)
                            .frame(width: 10, height: 10)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
            }
        }
        .frame(height: 55)
        .task {
            if !notification.isRead {
                modifyNotification(action: "read")
            }
        }
    }
}

#Preview {
    NotificationModelView(notification: NotificationItem(id: "", title: "Welcome to Olympsis!", body: "You've Joined a great community!", type: "", category: "", isRead: false, createdAt: Date()))
        .environment(SessionStore())
}
