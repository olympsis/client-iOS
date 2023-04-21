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
                        currentTab = .activity
                    }
                } label: {
                    Image(systemName: currentTab == .activity ? "chart.bar.fill" : "chart.bar")
                        .imageScale(.large)
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(currentTab == .activity ? Color("secondary-color") : .white )
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
                            if let img = user.imageURL {
                                AsyncImage(url: URL(string: GenerateImageURL(img))){ phase in
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
        }.frame(height: 40)
        .padding(.bottom, 5)
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
