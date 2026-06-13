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
    
    @ToolbarContentBuilder
    private var nameToolbarItem: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .navigationBarLeading) {
                guard let user = session.user,
                      let username = user.username else {
                    return Text("olympsis-user")
                        .fixedSize()
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                }
                return Text(username)
                    .fixedSize()
                    .font(.title2)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }.sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .navigationBarLeading) {
                guard let user = session.user,
                      let username = user.username else {
                    return Text("olympsis-user")
                        .fixedSize()
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                }
                return Text(username)
                    .fixedSize()
                    .font(.title2)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
            }
        }
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
                    
                    // MARK: - Archive
                    // Inline archive of the user's past events. Generates on first appearance
                    // and loads from cache on subsequent visits.
                    ArchiveView()
                        .padding(.bottom)
                        .environment(session)
                }
                .fullScreenCover(isPresented: $showMenu, content: {
                    ProfileMenu()
                })
                .toolbar {
                    nameToolbarItem
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{ self.showMenu.toggle() }){
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(Color.Foreground.default)
                        }
                    }
                }
            }.background(Color.Background.primary)
        }
    }
}

#Preview {
    Profile()
        .environment(SessionStore())
}
