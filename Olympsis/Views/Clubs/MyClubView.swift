//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MyClubView: View {
    
    @Binding var club: Club
    @State var posts = [Post]()
    @State var status: LOADING_STATE = .pending
    @State private var showCreatePost       = false
    
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func GetData(uuid: String) -> UserPeek? {
        let usr = club.members.first(where: {$0.uuid == uuid})
        if let u = usr {
            return u.data
        }
        return nil
    }
    
    var body: some View {
        VStack {
            if !posts.filter({$0.clubId == club.id}).isEmpty{
                ZStack(alignment: .bottomTrailing){
                    ScrollView(showsIndicators: false) {
                        if status == .loading {
                            ProgressView()
                        } else {
                            ForEach(posts.filter({$0.clubId == club.id}).sorted{$0.createdAt > $1.createdAt}){ post in
                                PostView(club: club, post: post, data: GetData(uuid: post.owner), posts: $posts)
                            }.padding(.top)
                        }
                    }
                    .fullScreenCover(isPresented: $showCreatePost) { CreateNewPost(club: club, posts: $posts) }
                        .refreshable {
                            Task {
                                let _posts = await postObserver.fetchPosts(clubId:club.id)
                                await MainActor.run {
                                    posts = _posts
                                }
                            }
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
                        .padding(.bottom, 20)
                }.frame(width: SCREEN_WIDTH)
            } else {
                NoPostsView(club: club, posts: $posts)
            }
        }
        .task {
            if posts.isEmpty  {
                status = .loading
                let resp = await postObserver.fetchPosts(clubId: club.id)
                posts = resp
                status = .success
            }
        }
    }
}

struct MyClubView_Previews: PreviewProvider {
    static var previews: some View {
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        MyClubView(club: .constant(club)).environmentObject(SessionStore())
    }
}
