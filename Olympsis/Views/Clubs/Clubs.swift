//
//  Clubs.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI
import AlertToast

struct Clubs: View {
    
    @State var index = 0
    @State private var posts = [Post]()
    @State private var showMenu         = false
    @State private var showNewClubCover = false
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            VStack {
                if $session.myClubs.isEmpty {
                    NoClubView()
                } else {
                    MyClubView(club: $session.myClubs[index], posts: $posts)
                        .fullScreenCover(isPresented: $showMenu) {
                            ClubMenu(club: session.myClubs[index], index: $index, posts: $posts)
                        }
                }
            }.toolbar {
                if session.myClubs.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Clubs")
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing){
                        Menu {
                            Button(action: { showNewClubCover.toggle() }){
                                Label("Create a Club", systemImage: "person.2")
                            }
                        } label: {
                            Image(systemName: "c.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(session.myClubs[index].name)
                            .font(.title)
                            .bold()
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{ self.showMenu.toggle() }) {
                            AsyncImage(url: URL(string: session.myClubs[index].imageURL)){ image in
                                image.resizable()
                                    .clipShape(Circle())
                                    .frame(width: 30, height: 30)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    
                            } placeholder: {
                                Circle()
                                    .foregroundColor(.gray)
                                    .opacity(0.3)
                                    .frame(width: 40)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Clubs_Previews: PreviewProvider {
    static var previews: some View {
        Clubs().environmentObject(SessionStore())
    }
}
