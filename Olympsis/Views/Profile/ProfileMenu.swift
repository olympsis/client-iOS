//
//  ProfileMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI
import FirebaseAuth

struct ProfileMenu: View {
    
    enum AlertType {
        case logout
        case deletion
    }
    
    @State private var tapCount: Int = 0
    @State private var showAlert: Bool = false
    @State private var showDeleteView: Bool = false
    @State private var alertType: AlertType = .logout
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    @AppStorage("app_mode") private var appMode: APP_MODE?
    @AppStorage("app_state") private var appState: APP_STATE?
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "0.0"
        }
    }
    
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

                    NavigationLink(destination: TermsOfUse()) {
                        MenuLabel(icon: Image(systemName: "text.viewfinder"), text: "Terms of Use")
                    }
                    
                    NavigationLink(destination: PrivacyPolicy()) {
                        MenuLabel(icon: Image(systemName: "lock.fill"), text: "Privacy Policy")
                    }

                    NavigationLink(destination: AboutUs()) {
                        MenuLabel(icon: Image(systemName: "info.circle.fill"), text: "About Us")
                    }
                    
                    if (appState != nil) && appState == .developer {
                        NavigationLink(destination: LogViewer()) {
                            MenuLabel(icon: Image(systemName: "text.word.spacing"), text: "Logs")
                        }
                    }
                    
                    MenuButton(icon: Image(systemName: "door.left.hand.open"), text: "Logout", action: {
                        alertType = .logout
                        self.showAlert.toggle()
                    }, type: .destructive)
                    
                    MenuButton(icon: Image(systemName: "delete.forward"), text: "Delete Account", action: {
                        alertType = .deletion
                        self.showAlert.toggle()
                    }, type: .destructive)
                 
                    Spacer(minLength: 80)
                    
                    VStack {
                        Text("version")
                        Text(appVersion)
                    }
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .onTapGesture {
                        tapCount += 1
                        if tapCount == 7 {
                            withAnimation {
                                appState = .developer
                                tapCount = 0
                            }
                        }
                    }
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
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(Color.Background.primary)
            .alert(isPresented: $showAlert) {
                switch alertType {
                case .logout:
                    return Alert(
                        title: Text("Logging out?"),
                        message: Text("Are you sure you want to logout?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Logout"), action: {
                            Task {
                                await session.logout()
                            }
                        })
                    );
                case .deletion:
                    return Alert(
                        title: Text("Are you sure?"),
                        message: Text("Deletin your account means that you will loose all of your info on Olympsis"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            Task {
                                await session.deleteAccount()
                            }
                        })
                    );
                }
            }
        }
    }
}

#Preview("Profile Menu") {
    ProfileMenu()
        .environment(SessionStore())
}
