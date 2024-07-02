//
//  Profile.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {

    @State private var showMenu = false
    @EnvironmentObject private var session: SessionStore
    
    var username: String {
        guard let user = session.user,
              let username = user.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var body: some View {
        NavigationStack {
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
                    
                }
                .fullScreenCover(isPresented: $showMenu, content: {
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
                                .foregroundStyle(Color("foreground"))
                                .overlay {
                                    if session.invitations.count > 0 {
                                        NotificationCountView(value: $session.invitations.count)
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Profile()
        .environmentObject(SessionStore())
}
