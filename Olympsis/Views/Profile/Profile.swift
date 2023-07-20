//
//  Settings.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {

    @State private var showMenu = false
    @State private var userObserver = UserObserver()
    
    @EnvironmentObject private var session: SessionStore
    
    var username: String {
        guard let user = session.user,
              let name = user.username else {
            return "olympsis-user"
        }
        return name
    }
    
    var body: some View {
        
        var imageURL = Binding(
            get: {
                guard let user = session.user,
                      let url = user.imageURL else {
                    return ""
                }
                return url
            }) { val in }
        
        return NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    if let u = session.user {
                        ProfileModel(imageURL: imageURL, firstName: u.firstName!, lastName: u.lastName!, friendsCount:  0, bio: u.bio ?? "")
                            .padding(.top, 20)
                            .padding(.leading)
                    } else {
                        ProfileModelTemplate()
                            .padding(.top, 20)
                            .padding(.leading)
                            .padding(.bottom)
                    }
                    
                    // Edit profile button
                    EditProfileButton(userObserver: userObserver, imageURL: imageURL)
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
