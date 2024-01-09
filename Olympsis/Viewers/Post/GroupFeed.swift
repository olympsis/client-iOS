//
//  GroupFeed.swift
//  Olympsis
//
//  Created by Joel on 12/29/23.
//

import SwiftUI

struct GroupFeed: View {
    
    @State var posts: [Post] = [Post]()
    @State var selectedPost: Post?
    @State private var status: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    func isPinned(post: Post) -> Bool {
        guard let selectedGroup = session.selectedGroup else {
            return false
        }
        if selectedGroup.type == GROUP_TYPE.Club.rawValue {
            guard let club = selectedGroup.club else {
                return false
            }
            if post.type == "announcement" {
                if let data = club.data,
                   let parent = data.parent {
                    return post.id == parent.pinnedPostId
                }
            }
            return post.id == club.pinnedPostId
        } else {
            guard let org = selectedGroup.organization,
                  let pinnedPostId = org.pinnedPostId else {
                return false
            }
            return post.id == pinnedPostId
        }
    }
    
    func getLatestPosts() async -> [Post] {
        // this error should never happen but you never know :)
        guard let selectedGroup = session.selectedGroup else {
            status = .failure
            return [Post]()
        }
        
        // sorting condition for posts.
        // if the parent org has a pinned post that take priority #1
        // if the club has a pinned post then that takes priority #2
        // then the rest of the posts are sorted by when they were created
        let condition: (Post, Post) -> Bool = { p, p2 in
            return p.createdAt ?? 0 > p2.createdAt ?? 0
        }
        
        // make query to backend for posts
        if selectedGroup.type == GROUP_TYPE.Club.rawValue {
            status = .success
            guard let club = selectedGroup.club else {
                return [Post]()
            }
            guard let response: [Post] = await session.postObserver.getPosts(clubId: club.id ?? "", parentId: club.parentId) else {
                return [Post]()
            }
            
            var pinned = [Post]()
            var sorted = response.sorted(by: condition)
            
            if let data = club.data,
                let parent = data.parent,
                let pinnedPostId = parent.pinnedPostId {
                if let resp = sorted.first(where: { $0.id == pinnedPostId }) {
                    pinned.append(resp)
                }
            }
            if let pinnedPostId = club.pinnedPostId {
                if let resp = sorted.first(where: { $0.id == pinnedPostId }) {
                    pinned.append(resp)
                }
            }
            
            sorted.removeAll { p in
                pinned.contains(where: { $0.id == p.id })
            }
            
            for (index, element) in pinned.enumerated() {
                sorted.insert(element, at: index)
            }
            
            return sorted
        } else {
            status = .success
            guard let org = selectedGroup.organization else {
                return [Post]()
            }
            guard let response: [Post] = await session.postObserver.getPosts(clubId: org.id ?? "", parentId: nil) else {
                return [Post]()
            }
            
            var pinned = [Post]()
            var sorted = response.sorted(by: condition)
            
            if let org = selectedGroup.organization,
                let pinnedPostId = org.pinnedPostId {
                if let resp = sorted.first(where: { $0.id == pinnedPostId }) {
                    pinned.append(resp)
                }
            }
            
            sorted.removeAll { p in
                pinned.contains(where: { $0.id == p.id })
            }
            
            for (index, element) in pinned.enumerated() {
                sorted.insert(element, at: index)
            }
            
            return sorted
        }
    }
    

    
    var body: some View {
        switch status {
        case .loading:
            ProgressView()
        case .pending, .success:
            ScrollView(showsIndicators: false) {
                if posts.count > 0 {
                    ForEach(posts) { post in
                        PostView(post: post, posts: $posts)
                    }
                } else {
                    VStack {
                        Text("No Posts Found 😞")
                        Button(action: { Task { self.posts = await getLatestPosts() }}) {
                            Text("Try again")
                                .font(.callout)
                        }
                    }.padding(.top, 50)
                }
            }.task{
                self.posts = await getLatestPosts()
            }
            .onChange(of: session.selectedGroup, perform: { value in
                Task {
                    self.posts = await getLatestPosts()
                }
            })
            .refreshable {
                Task {
                    self.posts = await getLatestPosts()
                }
            }
        case .failure:
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("😣")
                        .font(.title)
                    Text("Failed to load feed")
                    Button(action: { Task { self.posts = await getLatestPosts() }}) {
                        Text("Try again")
                            .font(.callout)
                    }
                }.padding(.top, 50)
            }.refreshable {
                Task {
                    self.posts = await getLatestPosts()
                }
            }
        }
    }
}

#Preview {
    GroupFeed()
        .environmentObject(SessionStore())
}
