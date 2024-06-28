//
//  GroupFeed.swift
//  Olympsis
//
//  Created by Joel on 12/29/23.
//

import SwiftUI

struct GroupFeed: View {
    
    @Binding var showNewPost: Bool
    @Binding var showNewEvent: Bool
    @State private var showEvents: Bool = false
    
    @State private var status: LOADING_STATE = .loading
    
    @StateObject private var viewModel: FeedViewModel = FeedViewModel()
    @EnvironmentObject private var session: SessionStore
    
//    init(posts: [Post], selectedPost: Post? = nil) {
//        self.posts = posts
//        self.selectedPost = selectedPost
//        self.showNewPost = showNewPost
//        self.showEvents = showEvents
//        self.status = status
//    }
    
    var groupEvents: [Event] {
        guard let selectedGroup = session.selectedGroup else {
            return [Event]()
        }
        switch selectedGroup.type {
        case .Club:
            return session.events.filter { event in
                guard let club = selectedGroup.club else {
                    return false
                }
                return event.organizers?.contains(where: { $0.id == club.id  || club.parent?.id == $0.id}) ?? false
            }
        case .Organization:
            return session.events.filter { event in
                guard let org = selectedGroup.organization else {
                    return false
                }
                return event.organizers?.contains(where: { $0.id == org.id }) ?? false
            }
        }
    }
    
    func isPinned(post: Post) -> Bool {
        guard let selectedGroup = session.selectedGroup else {
            return false
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                return false
            }
            if post.type == "announcement" {
                if let parent = club.parent {
                    return ((parent.pinnedPosts?.contains(where: { $0 == post.id })) != nil)
                }
            }
            return club.pinnedPosts?.contains(post.id ?? "") ?? false
        } else {
            guard let org = selectedGroup.organization,
                  let pinnedPosts = org.pinnedPosts else {
                return false
            }
            return pinnedPosts.contains(where: { $0 == post.id })
        }
    }
    
    @MainActor
    func getLatestPosts() async -> [Post] {
        status = .loading
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
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                return [Post]()
            }
            guard let response: [Post] = await session.postObserver.getPosts(clubId: club.id ?? "", parentId: club.parent?.id) else {
                return [Post]()
            }
            
            var pinned = [Post]()
            var sorted = response.sorted(by: condition)
            
            if let parent = club.parent,
                let pinnedPosts = parent.pinnedPosts {
                if let resp = sorted.first(where: { val in pinnedPosts.contains(where: { val.id == $0 })}) {
                    pinned.append(resp)
                }
            }
            if let pinnedPosts = club.pinnedPosts {
                if let resp = sorted.first(where: { pinnedPosts.contains($0.id ?? "") }) {
                    pinned.append(resp)
                }
            }
            
            sorted.removeAll { p in
                pinned.contains(where: { $0.id == p.id })
            }
            
            for (index, element) in pinned.enumerated() {
                sorted.insert(element, at: index)
            }
            status = .success
            return sorted
        } else {
            guard let org = selectedGroup.organization else {
                return [Post]()
            }
            guard let response: [Post] = await session.postObserver.getPosts(clubId: org.id ?? "", parentId: nil) else {
                return [Post]()
            }
            
            var pinned = [Post]()
            var sorted = response.sorted(by: condition)
            
            if let org = selectedGroup.organization,
                let pinnedPosts = org.pinnedPosts {
                if let resp = sorted.first(where: { post in
                    return pinnedPosts.contains(where: { $0 == post.id })
                }) {
                    pinned.append(resp)
                }
            }
            
            sorted.removeAll { p in
                pinned.contains(where: { $0.id == p.id })
            }
            
            for (index, element) in pinned.enumerated() {
                sorted.insert(element, at: index)
            }
            status = .success
            return sorted
        }
    }

    
    var body: some View {
        VStack {
            switch status {
            case .loading:
                ScrollView {
                    VStack {
                        PostTemplateView(type: "")
                            .padding(.vertical)
                        PostTemplateView(type: "")
                            .padding(.vertical)
                        PostTemplateView(type: "")
                            .padding(.vertical)
                        PostTemplateView(type: "")
                    }
                }
            case .pending, .success:
                ScrollView {
                    if groupEvents.count > 0  {
                        VStack{
                            HStack {
                                Text("Events")
                                    .bold()
                                Spacer()
                                Button(action:{ showEvents.toggle() }) {
                                    HStack {
                                        Text("More")
                                            .lineLimit(1)
                                        Image(systemName: "chevron.down")
                                    }
                                }
                            }.fullScreenCover(isPresented: $showEvents, content: {
                                EventsList(events: groupEvents)
                            })
                            
                            if let event = groupEvents.first {
                                EventListItem(event: event)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    
                    if viewModel.posts.count > 0 {
                        ForEach(viewModel.posts) { post in
                            PostView(post: post)
                                .environmentObject(viewModel)
                        }
                    } else {
                        VStack {
                            Rectangle()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                                .foregroundStyle(Color.background)
                                .overlay {
                                    VStack {
                                        Text("No posts found")
                                            .foregroundStyle(Color.foreground)
                                        
                                        Button(action: { self.showNewPost.toggle() }) {
                                            Text("Create One")
                                                .font(.callout)
                                                .padding(.vertical, 5)
                                        }
                                    }
                                }
                        }.padding(.vertical)
                    }
                }
                .onChange(of: session.selectedGroup, { _, _ in
                    Task {
                        self.viewModel.posts = await getLatestPosts()
                    }
                })
                .refreshable {
                    Task {
                        self.viewModel.posts = await getLatestPosts()
                    }
                }
            case .failure:
                ScrollView(showsIndicators: false) {
                    VStack {
                        Rectangle()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .foregroundStyle(Color.background)
                            .overlay {
                                VStack {
                                    Text("😣")
                                        .font(.title)
                                    Text("Failed to load posts")
                                        .foregroundStyle(Color.foreground)
                                    Button(action: {
                                        Task { 
                                            self.viewModel.posts = await getLatestPosts()
                                        }
                                    }) {
                                        Text("Try again")
                                            .font(.callout)
                                    }
                                }
                            }
                        
                    }.padding(.vertical)
                }
                .refreshable {
                    Task {
                        self.viewModel.posts = await getLatestPosts()
                    }
                }
            }
        }
        .task {
            self.viewModel.posts = await getLatestPosts()
        }
        .fullScreenCover(isPresented: $showNewPost) {
            if let group = session.selectedGroup {
                if let club = group.club {
                    PostCreator(type: .Post, groupId: club.id ?? "")
                        .environmentObject(viewModel)
                } else if let org = group.organization {
                    PostCreator(type: .Post, groupId: org.id ?? "")
                        .environmentObject(viewModel)
                }
            }
        }
        .fullScreenCover(isPresented: $showNewEvent, content: {
            NewEvent(manager: NewEventManager())
        })
    }
}

#Preview {
    GroupFeed(showNewPost: .constant(false), showNewEvent: .constant(false))
        .environmentObject(SessionStore())
        .environmentObject(FeedViewModel())
}
