//
//  ContentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI

struct ViewContainer: View {
    @State var currentTab = Tab.home
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                Home().tag(Tab.home)
                Clubs().tag(Tab.club)
                MapView().tag(Tab.map)
                Tournaments().tag(Tab.tournament)
                Settings().tag(Tab.setting)
            }
            TabBar(currentTab: $currentTab)
        }.background(Color("dark-color"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ViewContainer()
    }
}
