//
//  PostsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/17/23.
//

import SwiftUI

struct PostsView: View {
    
    @Binding var club: Club
    @State var showPostMenu = false
    @State private var selectedPostIndex = 0
    @EnvironmentObject var session:SessionStore
    
    var posts: [Post] {
        return club.posts?.sorted{$0.createdAt! > $1.createdAt!} ?? [Post]()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(club.posts?.sorted{$0.createdAt! > $1.createdAt!} ?? [Post]()){ post in
                PostView(club: $club, post: post, index: $selectedPostIndex, showMenu: $showPostMenu)
                    .sheet(isPresented: $showPostMenu) {
                        PostMenu(club: $club, post: club.posts?[selectedPostIndex])
                            .presentationDetents([.height(250)])
                    }
                    .padding(.bottom, 1)
                    .padding(.bottom, (post.id! == posts.last?.id!) ? 20 : 0)
            }.padding(.top)
        }.refreshable {
            Task {
                guard let id = club.id else {
                    return
                }
                let resp = await session.postObserver.getPosts(clubId: id)
                club.posts = resp ?? [Post]()
            }
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView(club: .constant(CLUBS[0])).environmentObject(SessionStore())
    }
}
