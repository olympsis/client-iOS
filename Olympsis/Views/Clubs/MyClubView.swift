//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MyClubView: View {
    
    @Binding var club: Club
    @State var status: LOADING_STATE = .loading
    @State var showPostMenu = false
    @State private var showCreatePost = false
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var posts: [Post] {
        return club.posts?.sorted{$0.createdAt! > $1.createdAt!} ?? [Post]()
    }
    
    var clubID: String {
        guard let id = club.id else {
            return ""
        }
        return id
    }
    
    var body: some View {
        VStack {
            if (club.posts != nil) {
                PostsView(club: $club)
            } else {
                NoPostsView(club: $club)
            }
        }
        .task {
            guard club.posts == nil,
                    let id = club.id else {
                return
            }
            status = .loading
            let posts = await session.postObserver.getPosts(clubId: id)
            self.club.posts = posts
            status = .success
        }
    }
}

struct MyClubView_Previews: PreviewProvider {
    static var previews: some View {
        MyClubView(club: .constant(CLUBS[0])).environmentObject(SessionStore())
    }
}
