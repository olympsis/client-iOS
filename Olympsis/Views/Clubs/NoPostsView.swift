//
//  NoPostsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct NoPostsView: View {
    
    @Binding var club: Club
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
                Task {
                    guard let id = club.id else {
                        return
                    }
                    let posts = await session.postObserver.getPosts(clubId: id)
                    self.club.posts = posts?.sorted{$0.createdAt! > $1.createdAt!}
                }
            }
            .fullScreenCover(isPresented: $showCreatePost) {
                CreateNewPost(club: club)
            }
        }
    }
}


struct NoPostsView_Previews: PreviewProvider {
    static var previews: some View {
        NoPostsView(club: .constant(CLUBS[0]))
    }
}
