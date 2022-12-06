//
//  Settings.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {
    @State private var user: UserStore?
    @State private var showMenu = false
    @StateObject private var userObserver = UserObserver()
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    if let u = user {
                        ProfileModel(imageURL: u.imageURL ?? "", firstName: u.firstName, lastName: u.lastName, friendsCount: u.friends!.count, bio: u.bio)
                            .padding(.top, 20)
                            .padding(.leading)
                    }
                    
                    // Edit profile button
                    EditProfileButton(userObserver: userObserver)
                        .padding(.bottom, 30)
                    
                    // Badges View
                    BadgesView()
                    
                    // Trophies View
                    TrophiesView()
                    
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("@ \(session.user?.username ?? "unnamed_user")")
                            .foregroundColor(.primary)
                            .font(.custom("ITCAvantGardeStd-bk", size: 20, relativeTo: .largeTitle))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{ self.showMenu.toggle() }){
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .onAppear {
                    user = session.user
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
