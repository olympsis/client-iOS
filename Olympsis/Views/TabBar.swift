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
                            .foregroundColor(currentTab == .home ? Color("color-secnd") : .white )
                        Text("HOME")
                            .font(.caption2)
                            .foregroundColor(currentTab == .home ? Color("color-secnd") : .white )
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
                            .foregroundColor(currentTab == .club ? Color("color-secnd") : .white )
                        Text("GROUPS")
                            .font(.caption2)
                            .foregroundColor(currentTab == .club ? Color("color-secnd") : .white )
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
                            .foregroundColor(currentTab == .map ? Color("color-secnd") : .white )
                        Text("NEARBY")
                            .font(.caption2)
                            .foregroundColor(currentTab == .map ? Color("color-secnd") : .white )
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
                        if let user = session.user {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(currentTab == .profile ? Color("color-secnd") : .white )
                                if let img = user.imageURL,
                                 img != "" {
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
                                    }.frame(width: 18, height: 18)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .frame(maxWidth: .infinity)
                                        .overlay {
                                            Image(systemName: "person")
                                                .imageScale(.small)
                                                .foregroundStyle(currentTab == .profile ? .white : Color("color-secnd") )
                                        }
                                        .foregroundColor(currentTab == .profile ? Color("color-secnd") : .white )
                                }
                            }
                        } else {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .frame(maxWidth: .infinity)
                                .overlay {
                                    Image(systemName: "person")
                                        .imageScale(.small)
                                        .foregroundStyle(currentTab == .profile ? .white : Color("color-secnd") )
                                }
                                .foregroundColor(currentTab == .profile ? Color("color-secnd") : .white )
                        }
                        Text("PROFILE")
                            .font(.caption2)
                            .foregroundColor(currentTab == .profile ? Color("color-secnd") : .white )
                    }
                }
            }.frame(maxWidth: .infinity)
                .frame(height: 25)
        }.frame(height: 25)
        .padding([.horizontal, .vertical])
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(currentTab: .constant(.home)).environmentObject(SessionStore())
            .background(Color("dark-color"))
    }
}
