//
//  Settings.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {

    @State private var showMenu = false
    @EnvironmentObject private var session: SessionStore
    
    @State private var username: String = "olympsis-user"
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    ProfileModel(userData: $session.user)
                        .padding(.top, 20)
                        .padding(.leading)
                    
                    // Edit profile button
                    EditProfileButton()
                        .padding(.bottom, 30)
                    
                    // Badges View
                    BadgesView()
                    
                    // Trophies View
                    TrophiesView()
                    
                }.fullScreenCover(isPresented: $showMenu, content: {
                    ProfileMenu()
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(username)
                            .foregroundColor(.primary)
                            .font(.title2)
                            .fontWeight(.regular)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{ self.showMenu.toggle() }){
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Profile().environmentObject(SessionStore())
    }
}
