//
//  ContentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI

struct ViewContainer: View {
    @State var currentTab = Tab.home
    @State var showBeta = false
    
    @EnvironmentObject var session: SessionStore
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
                // mix stored user data with backend data
                await session.GenerateUpdatedUserData()
                
                // grab clubs data
                await session.generateClubsData()
            }
            .fullScreenCover(isPresented: $showBeta) {
                BetaPage()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ViewContainer()
    }
}
