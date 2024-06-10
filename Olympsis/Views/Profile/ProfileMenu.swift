//
//  ProfileMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI
import FirebaseAuth

struct ProfileMenu: View {
    
    @State private var showDeleteView: Bool = false
    @EnvironmentObject var session:SessionStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    NavigationLink(destination: NotificationSettings()) {
                        MenuLabel(icon: Image(systemName: "bell.fill"), text: "Notification Settings")
                    }
                    
                    NavigationLink(destination: BugReportView()) {
                        MenuLabel(icon: Image(systemName: "ladybug"), text: "Report a bug")
                    }
                    
                    NavigationLink(destination: BlockedUsersList()) {
                        MenuLabel(icon: Image(systemName: "person.slash"), text: "Blocked Users")
                    }
                    
                    NavigationLink(destination: HelpGuide()) {
                        MenuLabel(icon: Image(systemName: "lifepreserver.fill"), text: "Help")
                    }

                    NavigationLink(destination: PrivacyPolicy()) {
                        MenuLabel(icon: Image(systemName: "lock.fill"), text: "Privacy Policy")
                    }

                    NavigationLink(destination: AboutUs()) {
                        MenuLabel(icon: Image(systemName: "info.circle.fill"), text: "About Us")
                    }
                    
                    NavigationLink(destination: LogViewer()) {
                        MenuLabel(icon: Image(systemName: "text.word.spacing"), text: "Logs")
                    }
                    
                    MenuButton(icon: Image(systemName: "door.left.hand.open"), text: "Logout", action: {
                        Task {
                            await session.logout()
                            dismiss()
                        }
                    }, type: .destructive)
                    
                    MenuButton(icon: Image(systemName: "delete.forward"), text: "Delete Account", action: {
                        self.showDeleteView.toggle()
                    }, type: .destructive)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{ dismiss() }){
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $showDeleteView, onDismiss: { dismiss() }) {
                    AccountDeleteSignin()
                }
            }
        }
    }
}

#Preview("Profile Menu") {
    ProfileMenu()
}
