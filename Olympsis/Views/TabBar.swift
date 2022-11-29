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
            HStack(spacing: 0) {
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .home
                    }
                } label: {
                    Image(systemName: currentTab == .home ? "house.fill" : "house")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(currentTab == .home ? Color("secondary-color") : .white )
                }
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .club
                    }
                } label: {
                    Image(systemName: currentTab == .club ? "person.3.fill" : "person.3")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(currentTab == .club ? Color("secondary-color") : .white )
                }
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .map
                    }
                } label: {
                    Image(systemName: currentTab == .map ? "map.fill" : "map")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(currentTab == .map ? Color("secondary-color") : .white )
                }
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .messages
                    }
                } label: {
                    Image(systemName: currentTab == .messages ? "bubble.right.fill" : "bubble.right")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(currentTab == .messages ? Color("secondary-color") : .white )
                }
                Button() {
                    withAnimation(.easeInOut(duration: 0.2)){
                        currentTab = .profile
                    }
                } label: {
                    if let user = session.user {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(currentTab == .profile ? Color("secondary-color") : .white )
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
                            }.frame(width: 25, height: 25)
                        }
                    } else {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(currentTab == .profile ? Color("secondary-color") : .white )
                    }
                    
                }
            }.frame(maxWidth: .infinity)
        }.frame(height: 20)
        .padding(.bottom, 10)
        .padding([.horizontal, .top])
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(currentTab: .constant(.home)).environmentObject(SessionStore())
            .background{
                Color.blue
            }
    }
}
