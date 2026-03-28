//
//  TabBar.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI
import Kingfisher

struct TabBar: View {
    
    @Binding var currentTab: ViewTab
    @State public var homeRouter = HomeRouter()
    @State public var groupRouter = GroupRouter()
    @State public var eventRouter = EventRouter()
    @State public var profileRouter = ProfileRouter()
    
    @Environment(SessionStore.self) private var session
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 0) {
//                Button() {
//                    withAnimation(.easeInOut(duration: 0.2)){
//                        currentTab = .home
//                        if currentTab == .home {
//                            homeRouter.navigateToRoot()
//                        }
//                    }
//                } label: {
//                    VStack {
//                        Image(systemName: currentTab == .home ? "house.fill" : "house")
//                            .imageScale(.large)
//                            .frame(maxWidth: .infinity)
//                            .foregroundStyle(Color.foreground)
//                    }
//                }
//                
//                Button() {
//                    withAnimation(.easeInOut(duration: 0.2)){
//                        currentTab = .club
//                        if currentTab == .club {
//                            groupRouter.navigateToRoot()
//                        }
//                    }
//                } label: {
//                    VStack {
//                        Image(systemName: currentTab == .club ? "person.2.fill" : "person.2")
//                            .imageScale(.large)
//                            .frame(maxWidth: .infinity)
//                            .foregroundStyle(Color.foreground)
//                    }
//                }
//                
//                if hideActivities != true {
//                    Button() {
//                        withAnimation(.easeInOut(duration: 0.2)){
//                            currentTab = .activity
//                        }
//                    } label: {
//                        VStack {
//                            Image(systemName: currentTab == .activity ? "bolt.fill" : "bolt")
//                                .imageScale(.large)
//                                .frame(maxWidth: .infinity)
//                                .foregroundStyle(Color.foreground)
//                        }
//                    }
//                }
                
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .events
                        if currentTab == .events {
                            eventRouter.navigateToRoot()
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "calendar")
                            .imageScale(.large)
                            .frame(maxWidth: .infinity)
                            .fontWeight(currentTab == .events ? .bold : .regular)
                            .foregroundStyle(
                                currentTab == .events
                                    ? (colorScheme == .dark ? .white : Color("color-prime"))
                                    : Color.foreground
                            )
                            .background {
                                if currentTab == .events && colorScheme == .dark {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("color-prime"))
                                        .frame(width: 36, height: 36)
                                }
                            }
                    }
                }
                
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .profile
                        if currentTab == .profile {
                            profileRouter.navigateToRoot()
                        }
                    }
                } label: {
                    VStack {
                        TabBarProfileLabel(currentTab: $currentTab)
                            .environment(session)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Circle()
                                    .stroke(
                                        currentTab == .profile
                                            ? (colorScheme == .dark ? .white : Color("color-prime"))
                                            : Color.foreground,
                                        lineWidth: currentTab == .profile ? 3 : 1
                                    )
                            )
                            .background {
                                if currentTab == .profile && colorScheme == .dark {
                                    Circle()
                                        .fill(Color("color-prime"))
                                        .frame(width: 36, height: 36)
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 25)
        }
        .frame(height: 25)
        .padding(.vertical)
    }
}

#Preview {
    TabBar(currentTab: .constant(.home))
        .environment(SessionStore())
}
