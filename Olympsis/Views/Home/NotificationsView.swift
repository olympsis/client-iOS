//
//  NotificationsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import SwiftUI

struct NotificationsView: View {
    
    @State private var notifications: [NotificationModel] = []
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack {
            if notifications.count > 0 {
                ScrollView(showsIndicators: false) {
                    ForEach(notifications, id: \.id){ note in
                        NotificationModelView(notification: note)
                    }
                }
            } else {
                Spacer()
                Text("No new notifications")
                Spacer()
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action:{ dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("color-prime"))
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            notifications = session.invitations.map({ i in
                NotificationModel(id: UUID().uuidString, type: "invitation", invite: i, body: "")
            })
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(SessionStore())
}
