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
    @State private var showCreatePost = false
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func GetData(uuid: String) -> UserData? {
        let usr = club.members!.first(where: {$0.uuid == uuid})
        if let u = usr {
            return u.data
        }
        return nil
    }
    
    var posts: [Post] {
        return session.posts[club.id ?? ""] ?? [Post]()
    }
    
    var body: some View {
        VStack {
            if !posts.isEmpty {
                ZStack(alignment: .bottomTrailing){
                    ScrollView(showsIndicators: false) {
                        if status == .loading {
                            ProgressView()
                        } else {
                            ForEach(posts.sorted{$0.createdAt! > $1.createdAt!}){ post in
                                PostView(club: club, post: post, data: post.data)
                            }.padding(.top)
                        }
                    }
                    .refreshable {
                        Task {
                            guard let id = club.id else {
                                return
                            }
                            await session.fetchClubPosts(id: id)
                        }
                    }
                }.frame(width: SCREEN_WIDTH)
            } else {
                NoPostsView(club: club)
            }
        }
        .task {
            guard posts.isEmpty, let id = club.id else {
                return
            }
            status = .loading
            await session.fetchClubPosts(id: id)
            status = .success
        }
    }
}

struct MyClubView_Previews: PreviewProvider {
    static var previews: some View {
        MyClubView(club: .constant(CLUBS[0])).environmentObject(SessionStore())
    }
}
