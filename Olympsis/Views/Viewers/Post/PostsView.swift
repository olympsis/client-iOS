//
//  PostsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/17/23.
//

import SwiftUI

struct PostsView: View {
    
    @State var club: Club
    @Binding var posts: [Post]
    @State private var showPostMenu = false
    @State private var selectedPostIndex = 0
    @EnvironmentObject var session:SessionStore
    
    func getPosts() async {
        guard let id = club.id,
              let resp = await session.postObserver.getPosts(clubId: id) else {
            return
        }
        
        posts = resp.sorted{$0.createdAt! > $1.createdAt!}
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if posts.count == 0 {
                Text("There are no posts")
                    .padding(.top)
                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT/1.2)
            } else {
                ForEach(posts.sorted{$0.createdAt! > $1.createdAt!}){ post in
                    PostView(club: $club, post: post, index: $selectedPostIndex, showMenu: $showPostMenu)
                        .sheet(isPresented: $showPostMenu) {
                            PostMenu(post: posts[selectedPostIndex], club: $club, posts: $posts)
                                .presentationDetents([.height(250)])
                        }
                        .padding(.bottom, 1)
                        .padding(.bottom, (post.id! == posts.last?.id!) ? 20 : 0)
                }.padding(.top)
            }
        }.refreshable {
            await getPosts()
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView(club: CLUBS[0], posts: .constant(POSTS)).environmentObject(SessionStore())
    }
}
