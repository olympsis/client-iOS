//
//  ContentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import MapKit
import SwiftUI
import Firebase
import Security
import SwiftToast
import AuthenticationServices

struct ViewContainer: View {
    
    @State var currentTab: Tab = .home
    @State private var showOnboarding: Bool = false
    
    @EnvironmentObject private var session: SessionStore
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                Home()
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar)
                
                GroupView()
                    .tag(Tab.club)
                    .toolbar(.hidden, for: .tabBar)
                
                MapView()
                    .tag(Tab.map)
                    .toolbar(.hidden, for: .tabBar)
                
                Activity()
                    .tag(Tab.activity)
                    .toolbar(.hidden, for: .tabBar)
                
                Profile()
                    .tag(Tab.profile)
                    .toolbar(.hidden, for: .tabBar)
            }
            .toast(
                isPresented: session.$notificationsManager.showToast,
                position: session.$notificationsManager.toastPosition,
                content: session.$notificationsManager.toastContent
            )
            .padding(.bottom, -10)
            
            TabBar(currentTab: $currentTab)
                .background(Color("dark-color"))
                .ignoresSafeArea(.keyboard)
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            Task {
                session.user?.hasOnboarded = true
                _ = await session.userObserver.UpdateUserData(update: UserDao(hasOnboarded: true))
            }
        }, content: {
            Onboarding()
        })
        .task {
            session.state = .loading
            await session.CheckIn()
            guard let user = session.user else {
                await session.logout()
                return
            }
            
            // If the sessionStore has recieved a location the home page will handle all that when it recieves a location from the loc manager
            if (!session.locationRecieved) {
                if let hometown = user.hometown {
                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]))
                } else {
                    await session.getNearbyData(location: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988))
                }
            }
            session.state = .success
            
            guard let hasOnboarded = user.hasOnboarded else {
                return
            }
            if !hasOnboarded {
                showOnboarding.toggle()
            }
        }
    }
}

#Preview {
    ViewContainer()
        .environmentObject(SessionStore())
}
