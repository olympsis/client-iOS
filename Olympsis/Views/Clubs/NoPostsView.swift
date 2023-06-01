//
//  NoPostsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct NoPostsView: View {
    
    @State var club: Club
    @Binding var posts: [Post]
    @State private var isLoading        = true
    @State private var showCreatePost   = false
    
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                Text("There are no posts")
                    .padding(.top)
                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT/1.2)
            }.refreshable {
                let posts = await postObserver.fetchPosts(clubId:club.id!)
                await MainActor.run(body: {
                    for post in posts {
                        session.posts.append(post)
                    }
                })
            }
            Button(action: { self.showCreatePost.toggle() }){
                ZStack {
                    Circle()
                        .foregroundColor(Color("secondary-color"))
                        .frame(width: 50)
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }.padding(.trailing)
                .padding(.bottom, 30)
                .fullScreenCover(isPresented: $showCreatePost, onDismiss: {
                    isLoading = true
                    Task {
                        let posts = await postObserver.fetchPosts(clubId:club.id!)
                        await MainActor.run(body: {
                            for post in posts {
                                session.posts.append(post)
                            }
                        })
                    }
                    isLoading = false
                }) { CreateNewPost(club: club, posts: $posts) }
        }
    }
}


struct NoPostsView_Previews: PreviewProvider {
    static var previews: some View {
        NoPostsView(club: CLUBS[0], posts: .constant([Post]()))
    }
}
