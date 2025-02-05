//
//  Profile.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {

    @State private var showMenu = false
    @Environment(SessionStore.self) private var session
    
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
                    
                    // MARK: - Profile View
                    ProfileModel()
                        .padding(.top, 20)
                        .padding(.horizontal)
                        .environment(session)
                    
                    // MARK: - Profile Button
                    EditProfileButton()
                        .padding(.bottom, 30)
                    
                    // MARK: - Badges View
                    BadgesView()
                    
                    // MARK: - Trophies View
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
                                .foregroundStyle(Color.foreground)
                        }
                    }
                }
            }.background(Color("background-color/primary"))
        }
    }
}

#Preview {
    Profile()
        .environment(SessionStore())
}
