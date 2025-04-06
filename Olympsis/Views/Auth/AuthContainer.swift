//
//  AuthContainer.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/22/22.
//

import SwiftUI

struct AuthContainer: View {
    
    @State var currentView = AuthTab.sports
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        TabView(selection: $currentView){
            AuthView(currentView: $currentView)
                .tag(AuthTab.auth)
                .toolbar(.hidden, for: .tabBar)
            
            AuthUserInfo(currentView: $currentView)
                .tag(AuthTab.info)
                .toolbar(.hidden, for: .tabBar)
            
            AuthUserSports(currentView: $currentView)
                .tag(AuthTab.sports)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    AuthContainer()
        .environment(SessionStore())
}
