//
//  TabBar.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var currentTab: Tab
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 0) {
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .home
                    }
                } label: {
                    VStack {
                        Image(systemName: currentTab == .home ? "house.fill" : "house")
                            .frame(width: 20, height: 20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white )
                        Text("HOME")
                            .font(.caption2)
                            .foregroundColor(.white )
                    }
                }
                
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .club
                    }
                } label: {
                    VStack {
                        Image(systemName: currentTab == .club ? "person.3.fill" : "person.3")
                            .frame(width: 20, height: 20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white )
                        Text("GROUPS")
                            .font(.caption2)
                            .foregroundColor(.white )
                    }
                }
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .map
                    }
                } label: {
                    VStack {
                        Image(systemName: currentTab == .map ? "map.fill" : "map")
                            .frame(width: 20, height: 20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white )
                        Text("EVENTS")
                            .font(.caption2)
                            .foregroundColor(.white )
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
                    }
                } label: {
                    VStack {
                        TabBarProfileLabel(currentTab: $currentTab)
                            .environmentObject(session)
                            .frame(maxWidth: .infinity)
                        
                        Text("PROFILE")
                            .font(.caption2)
                            .foregroundColor(.white )
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
    @Previewable @State var currentTab: Tab = .home
    return TabBar(currentTab: $currentTab)
        .background(Color.dark)
        .environmentObject(SessionStore())
        
}
