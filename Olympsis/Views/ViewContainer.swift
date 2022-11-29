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
                Messages().tag(Tab.messages)
                Profile().tag(Tab.profile)
            }
            TabBar(currentTab: $currentTab)
                .ignoresSafeArea(.keyboard)
        }.background(Color("dark-color"))
            /*.onAppear {
                showBeta = true
            }*/
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
