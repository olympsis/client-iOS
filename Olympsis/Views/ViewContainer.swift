//
//  ContentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI
import Security
import AuthenticationServices

struct ViewContainer: View {
    enum ACCOUNT_STATE {
        case Authorized
        case Revoked
        case NotFound
        case Transferred
        case Unknown
    }
    
    @State var currentTab: Tab = .home
    @State private var showBeta: Bool = false
    @State private var accountState: ACCOUNT_STATE = .Unknown
    
    @EnvironmentObject var session: SessionStore
    @AppStorage("loggedIn") private var loggedIn: Bool?
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                Home().tag(Tab.home)
                Clubs().tag(Tab.club)
                MapView().tag(Tab.map)
                Activity().tag(Tab.activity)
                Profile().tag(Tab.profile)
            }
            TabBar(currentTab: $currentTab)
                .ignoresSafeArea(.keyboard)
        }.background(Color("dark-color"))
            .task {
                await session.GenerateUpdatedUserData()
                await session.generateClubsData()
            }
            .fullScreenCover(isPresented: $showBeta) {
                BetaPage()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ViewContainer().environmentObject(SessionStore())
    }
}
