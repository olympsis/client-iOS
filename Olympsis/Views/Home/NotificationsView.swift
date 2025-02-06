//
//  NotificationsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import SwiftUI

struct NotificationsView: View {
    
    @State private var notifications: [NotificationModel] = []
    
    @Environment(HomeRouter.self) private var router
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        ScrollView {
            if notifications.count > 0 {
                ForEach(notifications, id: \.id){ note in
                    NotificationModelView(notification: note)
                }
            } else {
                VStack {
                    Text("No new notifications")
                    HStack {
                        Spacer()
                    }
                }.padding(.top, 50)
            }
        }
        .background(Color("background-color/primary"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action:{ router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.foreground)
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
            notifications = session.invitations.map({ i in
                NotificationModel(id: UUID().uuidString, type: "invitation", invite: i, body: "")
            })
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
