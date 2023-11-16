//
//  PostsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/17/23.
//

import SwiftUI

struct PostsView: View {
    
    @Binding var club: Club
    @Binding var index: Int
    @Binding var showNewPost: Bool
    
    @State private var posts = [Post]()
    @State private var showPostMenu = false
    @State private var selectedPostIndex = 0
    @State private var showMoreEvents = false
    @EnvironmentObject var session:SessionStore
    
    func getPosts() async {
        guard let id = session.clubs[index].id,
              let resp = await session.postObserver.getPosts(clubId: id) else {
            posts = [Post]()
            return
        }

        posts = resp.sorted{$0.createdAt! > $1.createdAt!}
    }
    
    var events: [Event]? {
        guard let id = club.id else {
            return nil
        }
        return session.events.filterByClubID(id: id)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if events != nil {
                VStack {
                    HStack {
                        Text("Events")
                            .font(.system(.headline))
                        .padding()
                        Spacer()
                        Button(action:{self.showMoreEvents.toggle()}){
                            Text("More")
                               .bold()
                            Image(systemName: "chevron.down")
                        }.padding()
                            .foregroundColor(Color.primary)
                    }
                    EventView(event: events![0])
                        .padding(.horizontal)
                }
            }
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
        .fullScreenCover(isPresented: $showNewPost) {
            CreateNewPost(club: club, posts: $posts)
        }
        .onChange(of: index, perform: { newValue in
            Task {
                await getPosts()
            }
        })
        .fullScreenCover(isPresented: $showMoreEvents) {
            EventsList(events: events ?? [Event]())
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView(club: .constant(CLUBS[0]), index: .constant(0), showNewPost: .constant(false)).environmentObject(SessionStore())
    }
}
