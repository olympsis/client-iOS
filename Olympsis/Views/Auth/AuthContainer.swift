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
                CreateAccount(currentView: $currentView).tag(AuthTab.create)
                Permissions(currentView: $currentView).tag(AuthTab.permissions)
            }
        }
    }
}

struct AuthContainer_Previews: PreviewProvider {
    static var previews: some View {
        AuthContainer()
    }
}
