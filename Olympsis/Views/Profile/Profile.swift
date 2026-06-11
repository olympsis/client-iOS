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
                    
                    NavigationLink(destination: PastEvents()) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 60)
                            .foregroundStyle(Color.Background.secondary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.Foreground.default.opacity(0.2), lineWidth: 1)
                            }
                            .overlay {
                                HStack(alignment: .center) {
                                    Image(systemName: "calendar.badge.checkmark")
                                    Text(String(localized: "profile-past-events", table: "Profile"))
                                        .fontWeight(.medium)
                                }
                            }
                    }.padding([.bottom, .horizontal])
                    
//                    HStack() {
//                        Button(action: {
//                            withAnimation(.smooth) {
//                                selectedTab = .achievements
//                            }
//                        }) {
//                            VStack {
//                                Text(String(localized: "awards", table: "Profile"))
//                                    .font(.callout)
//                                    .fontWeight(.medium)
//                                    
//                                
//                                Rectangle()
//                                    .frame(height: 1)
//                                    .foregroundStyle(selectedTab == .achievements ? Color.Foreground.default : Color.clear)
//                            }
//                        }
//                        
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            withAnimation(.smooth) {
//                                selectedTab = .groupsEnrolled
//                            }
//                        }) {
//                            VStack {
//                                Text(String(localized: "groups", table: "Profile"))
//                                    .font(.callout)
//                                    .fontWeight(.medium)
//                                
//                                Rectangle()
//                                    .frame(height: 1)
//                                    .foregroundStyle(selectedTab == .groupsEnrolled ? Color.Foreground.default : Color.clear)
//                            }
//                        }
//                        
//                        Spacer()
//                    }
//                    .padding(.bottom, 10)
//                    .padding(.horizontal)
//                    
//                    switch selectedTab {
//                    case .achievements:
//                        Awards()
//                            .environment(session)
//                        
//                    case .groupsEnrolled:
//                        GroupsEnrolled()
//                            .environment(session)
//                    }

                }
                .fullScreenCover(isPresented: $showMenu, content: {
                    ProfileMenu()
                })
                .toolbar {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text(username)
                                .fixedSize()
                                .font(.title2)
                                .fontWeight(.regular)
                                .foregroundColor(.primary)
                        }.sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text(username)
                                .fixedSize()
                                .font(.title2)
                                .fontWeight(.regular)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{ self.showMenu.toggle() }){
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(Color.Foreground.default)
                        }
                    }
                }
                .task {
                    Task {
                        guard session.pastEvents.isEmpty else { return }
                        let pastEvents = await session.eventObserver.fetchPastEvents()
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
