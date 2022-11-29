//
//  Settings.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {
    @StateObject private var userObserver = UserObserver()
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    HStack {
                        if let user = session.user {
                            AsyncImage(url: URL(string: user.imageURL ?? "")){ phase in
                                if let image = phase.image {
                                        image // Displays the loaded image.
                                            .resizable()
                                            .clipShape(Circle())
                                            .scaledToFill()
                                            .clipped()
                                    } else if phase.error != nil {
                                        Color.red // Indicates an error.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    } else {
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    }
                            }.frame(width: 100, height: 100)
                        } else {
                            Circle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading){
                            HStack(){
                                Text("\(session.getFirstName())")
                                    .font(.custom("ITCAvantGardeStd-Bold", size: 30, relativeTo: .largeTitle))
                                    .bold()
                                
                                Text("\(session.getLastName())")
                                    .font(.custom("ITCAvantGardeStd-Bold", size: 30, relativeTo: .largeTitle))
                                    .bold()
                            }.frame(height: 30)
                            Text("\(session.user?.friends?.count ?? 0) friends")
                                .frame(height: 30)
                        }.padding(.leading)
                        Spacer()
                    }.padding(.leading, 20)
                        .padding(.top, 20)
                    if let user = session.user {
                        Text(user.bio)
                            .padding(.leading, 25)
                            .padding(.top)
                            .padding(.bottom)
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
                        Menu {
                            Button(role: .destructive, action: {}){
                                Label("Logout", systemImage: "door.left.hand.open")
                            }
                        } label: {
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
