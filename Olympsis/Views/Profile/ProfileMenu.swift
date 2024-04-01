//
//  ProfileMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI

struct ProfileMenu: View {
    
    @State private var showHelp: Bool = false
    @State private var showAboutUs: Bool = false
    @State private var showPrivacy: Bool = false
    @State private var showBugReport: Bool = false
    @State private var showDeleteView: Bool = false
    @State private var showNotifications: Bool = false
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    MenuButton(icon: Image(systemName: "bell.fill"), text: "Notification Settings", action: {
                        self.showNotifications.toggle()
                    }).padding(.top)
                        .fullScreenCover(isPresented: $showNotifications, content: {
                            NotificationSettings()
                        })
                    
                    MenuButton(icon: Image(systemName: "ladybug"), text: "Report a bug"){
                        showBugReport.toggle()
                    }.fullScreenCover(isPresented: $showBugReport, content: {
                        BugReportView()
                    })
                    
                    MenuButton(icon: Image(systemName: "lifepreserver.fill"), text: "Help") {
                        self.showHelp.toggle()
                    }.fullScreenCover(isPresented: $showHelp, content: {
                        HelpGuide()
                    })
                    
                    MenuButton(icon: Image(systemName: "lock.fill"), text: "Privacy Policy") {
                        self.showPrivacy.toggle()
                    }.fullScreenCover(isPresented: $showPrivacy, content: {
                        PrivacyPolicy()
                    })
                        
                    MenuButton(icon: Image(systemName: "info.circle.fill"), text: "About Us") {
                        self.showAboutUs.toggle()
                    }.fullScreenCover(isPresented: $showAboutUs, content: {
                        AboutUs()
                    })
                    
                    MenuButton(icon: Image(systemName: "door.left.hand.open"), text: "Logout", action: {
                        Task {
                            await session.logout()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }, type: .destructive)
                    
                    MenuButton(icon: Image(systemName: "delete.forward"), text: "Delete Account", action: {
                        self.showDeleteView.toggle()
                    }, type: .destructive)
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $showDeleteView, onDismiss: { self.presentationMode.wrappedValue.dismiss() }) {
                    DeleteAccountView()
                }
            }
        }
    }
}

struct ProfileMenu_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMenu()
    }
}
