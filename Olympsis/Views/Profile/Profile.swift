//
//  Profile.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Profile: View {

    @State private var showMenu = false
    @State private var selectedTab = ProfileTabs.achievements
    
    @Environment(SessionStore.self) private var session
    
    enum ProfileTabs: Int {
        case achievements
        case groupsEnrolled
        case pastEvents
    }
    
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
                    
                    VStack(alignment: .leading) {
                        // MARK: - Profile View
                        ProfileModel()
                            .padding(.top, 20)
                            .padding(.horizontal)
                            .environment(session)
                        
                        // MARK: - Profile Button
                        EditProfileButton()
                            .padding(.bottom, 30)
                    }
                    
                    HStack() {
                        Button(action: {
                            withAnimation(.smooth) {
                                selectedTab = .achievements
                            }
                        }) {
                            VStack {
                                Text("Awards")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(selectedTab == .achievements ? Color.foreground : Color.clear)
                            }
                        }
                        
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.smooth) {
                                selectedTab = .groupsEnrolled
                            }
                        }) {
                            VStack {
                                Text("Groups")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(selectedTab == .groupsEnrolled ? Color.foreground : Color.clear)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.smooth) {
                                selectedTab = .pastEvents
                            }
                        }) {
                            VStack {
                                Text("Past Events")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(selectedTab == .pastEvents ? Color.foreground : Color.clear)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    switch selectedTab {
                    case .achievements:
                        Awards()
                            .environment(session)
                        
                    case .groupsEnrolled:
                        GroupsEnrolled()
                            .environment(session)
                        
                    case .pastEvents:
                        PastEvents()
                            .environment(session)
                    }

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
                .task {
                    Task {
                        guard let uuid = session.user?.uuid else {
                            return
                        }
                        let pastEvents = await session.eventObserver.getUserPastEvents(uuid: uuid)
                        session.pastEvents = Set(pastEvents)
                    }
                }
            }
        }
    }
}

#Preview {
    Profile()
        .environment(SessionStore())
}
