//
//  ContentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI
import Security
import SwiftToast
import AuthenticationServices

struct ViewContainer: View {
    
    @State var currentTab: Tab = .home
    @State private var showBeta: Bool = false
    @State private var accountState: ACCOUNT_STATE = .Unknown
    @State private var authObserver = AuthObserver()
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var notificationManager: NotificationManager
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                Home().tag(Tab.home)
                GroupView().tag(Tab.club)
                MapView().tag(Tab.map)
                Activity().tag(Tab.activity)
                Profile().tag(Tab.profile)
            }.toast(isPresented: $notificationManager.showToast, toast: $notificationManager.toastContent)
            
            TabBar(currentTab: $currentTab)
                .ignoresSafeArea(.keyboard)
        }.background(Color("dark-color"))
            .fullScreenCover(isPresented: $showBeta) {
                BetaPage()
            }
            .task {
                await session.fetchUser()
                session.locationManager.requestLocation()
            }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ViewContainer().environmentObject(SessionStore()).environmentObject(NotificationManager())
    }
}
