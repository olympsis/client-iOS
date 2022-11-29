//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MyClubView: View {
    
    @Binding var club: Club
    
    @Binding var posts: [Post]
    @State private var noPosts              = false
    @State private var isLoading            = true
    @State private var showCreatePost       = false
    
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if !posts.filter({$0.clubId == club.id}).isEmpty{
                ZStack(alignment: .bottomTrailing){
                    ScrollView(showsIndicators: false) {
                        if isLoading {
                            ProgressView()
                        } else {
                            ForEach(posts.filter({$0.clubId == club.id}).sorted{$0.createdAt > $1.createdAt}){ post in
                                PostView(post: post, posts: $posts)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showCreatePost, onDismiss: {
                        isLoading = true
                        Task {
                            let _posts = await postObserver.fetchPosts(clubId:club.id)
                            posts = _posts
                        }
                        isLoading = false
                    }) { CreateNewPost(clubId: club.id) }
                    
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
                        .padding(.bottom, 20)
                }.frame(width: SCREEN_WIDTH)
            } else {
                NoPostsView(club: club)
            }
        }
        .task {
            if posts.filter({$0.clubId == club.id}).isEmpty  {
                let resp = await postObserver.fetchPosts(clubId: club.id)
                posts = resp
                if posts.count < 1 {
                    noPosts = true
                }
            }
            isLoading = false
        }
    }
}

struct MyClubView_Previews: PreviewProvider {
    static var previews: some View {
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, isVisible: true, members: [Member](), rules: ["No fighting"])
        MyClubView(club: .constant(club), posts: .constant([Post]())).environmentObject(SessionStore())
    }
}
