//
//  GroupFeed.swift
//  Olympsis
//
//  Created by Joel on 12/29/23.
//

import os
import SwiftUI

struct GroupFeed: View {
    
    @Binding var showNewPost: Bool
    @Binding var showNewEvent: Bool
    @State private var showEvents: Bool = false
    
    @StateObject private var viewModel = FeedViewModel()
    @Environment(SessionStore.self) private var session
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "group_feed")
    
    private var selectedGroup: GroupSelection? {
        return session.groupsManager.selected
    }
    
    private var selectedGroupID: String {
        guard let selectedGroup,
              let id = selectedGroup.groupID else {
            return ""
        }
        return id
    }
    
    private var groupEvents: [Event] {
        guard let selectedGroup,
              let id = selectedGroup.groupID else {
            return []
        }
        
        return Array(session.events).filterByGroupID(id: id)
    }
    
    func isPinned(post: Post) -> Bool {
        guard let selectedGroup else {
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
            return club.pinnedPosts.contains(post.id)
        } else {
            guard let org = selectedGroup.organization else {
                return false
            }
            return org.pinnedPosts.contains(where: { $0 == post.id })
        }
    }
    
    var body: some View {
        VStack {
            switch viewModel.status {
            case .loading:
                ScrollView {
                    VStack {
                        PostTemplateView()
                            .padding(.vertical)
                        PostTemplateView()
                            .padding(.vertical)
                        PostTemplateView()
                            .padding(.vertical)
                        PostTemplateView()
                    }
                }
            case .pending, .success:
                ScrollView(showsIndicators: false) {
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
                                }.foregroundStyle(Color.Foreground.default)
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
                    
                    if viewModel.posts[selectedGroupID]?.count ?? 0 > 0 {
                        ForEach(viewModel.posts[selectedGroupID]?.sorted(by: { $0.createdAt > $1.createdAt }) ?? [Post]()) { post in
                            Spacer(minLength: 10)
                            
                            PostListItem(post: post)
                                .environmentObject(viewModel)
                        }
                    } else {
                        VStack {
                            Rectangle()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                                .foregroundStyle(Color.gray.opacity(0.3))
                                .overlay {
                                    VStack {
                                        Text("No posts found")
                                            .foregroundStyle(Color.Foreground.default)
                                        
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
                .refreshable {
                    Task {
                        await self.viewModel.getLatestPosts(session: session, refresh: true)
                    }
                }
            case .failure:
                ScrollView(showsIndicators: false) {
                    VStack {
                        Rectangle()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .overlay {
                                VStack {
                                    Text("😣")
                                        .font(.title)
                                    Text("Failed to load posts")
                                        .foregroundStyle(Color.Foreground.default)
                                    Button(action: {
                                        Task { 
                                            await self.viewModel.getLatestPosts(session: session)
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
                        await self.viewModel.getLatestPosts(session: session, refresh: true)
                    }
                }
            }
        }
        .task {
            if viewModel.posts.isEmpty {
                await self.viewModel.getLatestPosts(session: session)
            }
        }
        .fullScreenCover(isPresented: $showNewPost) {
            if let group = session.groupsManager.selected {
                if let club = group.club {
                    PostCreator(type: .Post, groupId: club.id)
                        .environmentObject(viewModel)
                } else if let org = group.organization {
                    PostCreator(type: .Announcement, groupId: org.id)
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
        .environment(SessionStore())
        .environmentObject(FeedViewModel())
}
