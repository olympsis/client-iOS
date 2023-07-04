//
//  AuthContainer.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/22/22.
//

import SwiftUI

struct AuthContainer: View {
    @State var currentView = AuthTab.auth
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentView){
                Auth(currentView: $currentView).tag(AuthTab.auth)
                PickUsername(currentView: $currentView).tag(AuthTab.username)
                PickSports(currentView: $currentView).tag(AuthTab.sports)
                Location(currentView: $currentView).tag(AuthTab.location)
                Notifications(currentView: $currentView).tag(AuthTab.notifications)
            }
        }
    }
}

struct AuthContainer_Previews: PreviewProvider {
    static var previews: some View {
        AuthContainer()
    }
}
