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
    @State private var toggleActivity: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    @AppStorage("app_mode") private var appMode: APP_MODE?
    @AppStorage("app_state") private var appState: APP_STATE?
    @AppStorage("hide_activities") private var hideActivities: Bool?
    
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
//                    Toggle(isOn: $toggleActivity) {
//                        VStack(alignment: .leading) {
//                            Text("Show Activities")
//                                .fontWeight(.medium)
//                            
//                            Text("Turn off to hide the Activities tab. Your workout data stays on device in Apple Health.")
//                                .font(.callout)
//                                .foregroundStyle(.gray)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 10)
//                    .onChange(of: toggleActivity) { _, newValue in
//                        Task { @MainActor in
//                            withAnimation {
//                                hideActivities = newValue
//                            }
//                            _ = await session.workoutManager.requestHealthStoreAuthorization()
//                        }
//                    }
                    
                    NavigationLink(destination: NotificationSettings().environment(session)) {
                        MenuLabel(icon: Image(systemName: "bell.fill"), text: String(localized: "setting-notifications", table: "Settings"))
                    }

                    NavigationLink(destination: LocalitySettings()) {
                        MenuLabel(icon: Image(systemName: "globe"), text: String(localized: "setting-locality", table: "Settings"))
                    }
                    
                    NavigationLink(destination: BugReportView()) {
                        MenuLabel(icon: Image(systemName: "ladybug"), text: String(localized: "setting-bug-report", table: "Settings"))
                    }
                    
                    NavigationLink(destination: BlockedUsersList()) {
                        MenuLabel(icon: Image(systemName: "person.slash"), text: String(localized: "setting-blocked-users", table: "Settings"))
                    }
                    
                    NavigationLink(destination: HelpGuide()) {
                        MenuLabel(icon: Image(systemName: "lifepreserver.fill"), text: String(localized: "setting-help", table: "Settings"))
                    }

                    NavigationLink(destination: TermsOfUse()) {
                        MenuLabel(icon: Image(systemName: "text.viewfinder"), text: String(localized: "setting-terms-of-use", table: "Settings"))
                    }
                    
                    NavigationLink(destination: PrivacyPolicy()) {
                        MenuLabel(icon: Image(systemName: "lock.fill"), text: String(localized: "setting-privacy-policy", table: "Settings"))
                    }

                    NavigationLink(destination: AboutUs()) {
                        MenuLabel(icon: Image(systemName: "info.circle.fill"), text: String(localized: "setting-about-us", table: "Settings"))
                    }
                    
                    if (appState != nil) && appState == .developer {
                        NavigationLink(destination: LogViewer()) {
                            MenuLabel(icon: Image(systemName: "text.word.spacing"), text: "Logs")
                        }

                        #if DEBUG
                        NavigationLink(destination: InAppNotificationDemoView()) {
                            MenuLabel(icon: Image(systemName: "bell.badge.fill"), text: "Notification Toasts")
                        }
                        #endif
                    }
                    
                    #if DEV
                    // Local dev only: drop straight back to DevAuth to sign in as a
                    // different seeded user. Deliberately skips the logout confirmation —
                    // swapping users is the normal loop when you have several simulators
                    // running side by side, and nothing is lost by doing it.
                    MenuButton(icon: Image(systemName: "person.2.fill"), text: "Switch Dev User (\(session.user?.username ?? "unknown"))", action: {
                        Task {
                            await session.logout()
                        }
                    })
                    #endif

                    MenuButton(icon: Image(systemName: "door.left.hand.open"), text: String(localized: "setting-logout", table: "Settings"), action: {
                        alertType = .logout
                        self.showAlert.toggle()
                    }, type: .destructive)
                    
                    MenuButton(icon: Image(systemName: "delete.forward"), text: String(localized: "setting-delete-account", table: "Settings"), action: {
                        alertType = .deletion
                        self.showAlert.toggle()
                    }, type: .destructive)
                 
                    Spacer(minLength: 80)
                    
                    VStack {
                        Text(String(localized: "version", table: "General"))
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
            }
            // The background belongs on the ScrollView, not the inner VStack:
            // the VStack is only as tall as its content, so a background there
            // leaves the empty area below it — and the navigation bar's
            // scroll-edge area — showing the system colour instead of ours.
            // `ignoresSafeArea` lets the colour bleed under the bar so the
            // toolbar reads as part of the same surface.
            .background(Color.Background.primary.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ dismiss() }){
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle(String(localized: "settings-title", table: "Settings"))
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let activity = hideActivities {
                    toggleActivity = activity
                }
            }
            .alert(isPresented: $showAlert) {
                switch alertType {
                case .logout:
                    return Alert(
                        title: Text(String(localized: "logging-out-warning-title", table: "Settings")),
                        message: Text(String(localized: "logging-out-warning-body", table: "Settings")),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text(String(localized: "setting-logout", table: "Settings")), action: {
                            Task {
                                await session.logout()
                            }
                        })
                    );
                case .deletion:
                    return Alert(
                        title: Text(String(localized: "delete-account-warning-title", table: "Settings")),
                        message: Text(String(localized: "delete-account-warning-body", table: "Settings")),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text(String(localized: "setting-delete-account", table: "Settings")), action: {
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
