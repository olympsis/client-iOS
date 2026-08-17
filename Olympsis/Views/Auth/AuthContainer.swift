//
//  AuthContainer.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/22/22.
//

import SwiftUI

struct AuthContainer: View {
    
    @State var currentView = AuthTab.auth
    
    // Apple credential data captured during Sign In with Apple
    @State var appleFirstName: String? = nil
    @State var appleLastName: String? = nil
    @State var appleEmail: String? = nil
    
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        #if DEV
        // Local development skips Sign in with Apple entirely — we pick which of the
        // seeded dev users to impersonate instead, so several simulators can each run
        // as a different user against the same server. See DevAuth.
        DevAuth()
        #else
        TabView(selection: $currentView){
            AuthView(currentView: $currentView, appleFirstName: $appleFirstName, appleLastName: $appleLastName, appleEmail: $appleEmail)
                .tag(AuthTab.auth)
                .toolbar(.hidden, for: .tabBar)
            
            AuthUserInfo(currentView: $currentView, appleFirstName: appleFirstName, appleLastName: appleLastName, appleEmail: appleEmail)
                .tag(AuthTab.info)
                .toolbar(.hidden, for: .tabBar)
            
            AuthUserSports(currentView: $currentView)
                .tag(AuthTab.sports)
                .toolbar(.hidden, for: .tabBar)
        }
        #endif
    }
}

#Preview {
    AuthContainer()
        .environment(SessionStore())
}

