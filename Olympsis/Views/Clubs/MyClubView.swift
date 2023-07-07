//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MyClubView: View {
    
    @Binding var club: Club
    @Binding var showNewPost: Bool
    @State private var posts = [Post]()
    @State private var showPostMenu = false
    @State private var showCreatePost = false
    @State private var status: LOADING_STATE = .loading
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func getPosts() async {
        status = .loading
        guard let id = club.id,
              let response = await session.postObserver.getPosts(clubId: id) else {
            return
        }
        posts = response.sorted{$0.createdAt! > $1.createdAt!}
        status = .success
    }
    
    var body: some View {
        VStack {
            PostsView(club: $club, posts: $posts)
        }
        .fullScreenCover(isPresented: $showNewPost, onDismiss: {
            Task {
                await getPosts()
            }
        }) {
            CreateNewPost(club: club)
        }
        .task {
            await getPosts()
        }
    }
    
}

struct MyClubView_Previews: PreviewProvider {
    static var previews: some View {
        MyClubView(club: .constant(CLUBS[0]), showNewPost: .constant(false)).environmentObject(SessionStore())
    }
}
