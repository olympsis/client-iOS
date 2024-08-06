//
//  AuthContainer.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/22/22.
//

import SwiftUI

struct AuthContainer: View {
    
    @State var currentView = AuthTab.auth
    
    var body: some View {
        TabView(selection: $currentView){
            AuthView(currentView: $currentView)
                .tag(AuthTab.auth)
                .toolbar(.hidden, for: .tabBar)
            UserDataCreation(currentView: $currentView)
                .tag(AuthTab.username)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    AuthContainer()
}
