//
//  Settings.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {
    
    @State private var imageURL = ""
    @State private var user: UserStore?
    @State private var showMenu = false
    @State private var userObserver = UserObserver()
    
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    if let u = user {
                        ProfileModel(imageURL: $imageURL, firstName: u.firstName, lastName: u.lastName, friendsCount: u.friends?.count ?? 0, bio: u.bio ?? "")
                            .padding(.top, 20)
                            .padding(.leading)
                    } else {
                        ProfileModelTemplate()
                            .padding(.top, 20)
                            .padding(.leading)
                            .padding(.bottom)
                    }
                    
                    // Edit profile button
                    EditProfileButton(userObserver: userObserver, imageURL: $imageURL)
                        .padding(.bottom, 30)
                    
                    // Badges View
                    BadgesView()
                    
                    // Trophies View
                    TrophiesView()
                    
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if let usr = session.user {
                            Text("@ \(usr.username)")
                                .foregroundColor(.primary)
                                .font(.title2)
                                .fontWeight(.regular)
                        } else {
                            Text("@ unnamed_user")
                                .foregroundColor(.primary)
                                .font(.title)
                                .fontWeight(.light)
                        }
                        
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
                    imageURL = user?.imageURL ?? ""
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
