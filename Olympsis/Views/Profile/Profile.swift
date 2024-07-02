//
//  Profile.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {

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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(username)
                            .foregroundColor(.primary)
                            .font(.title2)
                            .fontWeight(.regular)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            ProfileMenu()
                        } label: {
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
