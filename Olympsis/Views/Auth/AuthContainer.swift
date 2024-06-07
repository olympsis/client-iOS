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
                AuthView(currentView: $currentView).tag(AuthTab.auth)
                UserDataCreation(currentView: $currentView).tag(AuthTab.username)
            }
        }
    }
}

struct AuthContainer_Previews: PreviewProvider {
    static var previews: some View {
        AuthContainer()
    }
}
