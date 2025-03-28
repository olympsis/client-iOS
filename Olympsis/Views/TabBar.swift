//
//  TabBar.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var currentTab: ViewTab
    @State public var homeRouter = HomeRouter()
    @StateObject public var groupRouter = GroupRouter()
    @StateObject public var eventRouter = EventRouter()
    @StateObject public var profileRouter = ProfileRouter()
    
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 0) {
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .home
                        if currentTab == .home {
                            homeRouter.navigateToRoot()
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: currentTab == .home ? "house.fill" : "house")
                            .imageScale(.large)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.foreground)
                    }
                }
                
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .club
                        if currentTab == .club {
                            groupRouter.navigateToRoot()
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: currentTab == .club ? "person.2.fill" : "person.2")
                            .imageScale(.large)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.foreground)
                    }
                }
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .map
                        if currentTab == .map {
                            eventRouter.navigateToRoot()
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: currentTab == .map ? "calendar.circle.fill" : "calendar")
                            .imageScale(.large)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.foreground)
                    }
                }
//                Button() {
//                    withAnimation(.easeInOut(duration: 0.2)){
//                        currentTab = .activity
//                    }
//                } label: {
//                    Image(systemName: currentTab == .activity ? "chart.bar.fill" : "chart.bar")
//                        .imageScale(.large)
//                        .frame(width: 28, height: 28)
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(currentTab == .activity ? Color("color-secnd") : .white )
//                }
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
                                    .stroke(Color.foreground, lineWidth: currentTab == .profile ? 3 : 1)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 25)
            
        }
        .frame(height: 25)
        .padding([.horizontal, .vertical])
    }
}

#Preview {
    TabBar(currentTab: .constant(.home))
        .environment(SessionStore())
}
