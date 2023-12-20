//
//  OrgFeed.swift
//  Olympsis
//
//  Created by Joel on 12/1/23.
//

import SwiftUI

struct OrgFeed: View {
    @State var organization: Organization
    @State private var posts: [Post] = [Post]()
    @State private var showPostMenu = false
    @State private var selectedPostIndex = 0
    @State private var showMoreEvents = false
    @EnvironmentObject var session:SessionStore
    
    // array of the club's events
    var events: [Event]? {
        guard let id = organization.id else {
            return nil
        }
        return session.events.filterByGroupID(id: id)
    }
    
    // gets all of the posts for a club
    func getPosts() async {
        guard let selection = session.selectedGroup,
              let org = selection.organization,
              let id = org.id,
              let resp = await session.postObserver.getPosts(clubId: id, parentId: nil) else {
            return self.updatePosts(posts: [Post]())
        }
        self.updatePosts(posts: resp)
    }
    
    func updatePosts(posts: [Post]) {
        session.posts = posts.sorted{$0.createdAt! > $1.createdAt!}
        guard let id = session.selectedGroup?.id else {
            return
        }
        session.cachedPosts[id] = posts.sorted{$0.createdAt! > $1.createdAt!}
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
            if session.posts.count == 0 {
                Text("There are no posts")
                    .padding(.vertical)
                    .padding(.horizontal)
                .frame(height: SCREEN_HEIGHT/1.2)
            } else {
                ForEach(session.posts){ post in
                    PostView(post: post)
                        .sheet(isPresented: $showPostMenu) {
                            PostMenu(post: session.posts[selectedPostIndex])
                                .presentationDetents([.height(250)])
                        }
                        .padding(.bottom, 1)
                        .padding(.bottom, (post.id! == session.posts.last?.id!) ? 20 : 0)
                }.padding(.top)
            }
        }.task{
            await getPosts()
        }
        .refreshable {
            await getPosts()
        }
        .fullScreenCover(isPresented: $showMoreEvents) {
            EventsList(events: events ?? [Event]())
        }
        .onChange(of: session.selectedGroup, perform: { value in
            guard let id = value?.id,
                let cachedPosts = session.cachedPosts[id] else {
                session.posts = [Post]()
                Task {
                    await getPosts()
                }
                return
            }
            session.posts = cachedPosts
            Task {
                await getPosts()
            }
        })
    }
}

#Preview {
    OrgFeed(organization: ORGANIZATIONS[0])
}
