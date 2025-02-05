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
    
    var groupID: String {
        guard let selectedGroup = session.selectedGroup else {
            return ""
        }
        switch selectedGroup.type {
        case .Club:
            return selectedGroup.club?.id.lowercased() ?? ""
        case .Organization:
            return selectedGroup.club?.id.lowercased() ?? ""
        }
    }
    
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
                                }.foregroundStyle(Color.foreground)
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
                    
                    if viewModel.posts[groupID]?.count ?? 0 > 0 {
                        ForEach(viewModel.posts[groupID] ?? [Post]()) { post in
                            PostListItem(post: post)
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
                            .foregroundStyle(Color.background)
                            .overlay {
                                VStack {
                                    Text("😣")
                                        .font(.title)
                                    Text("Failed to load posts")
                                        .foregroundStyle(Color.foreground)
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
            if let group = session.selectedGroup {
                if let club = group.club {
                    PostCreator(type: .Post, groupId: club.id)
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
        .environment(SessionStore())
        .environmentObject(FeedViewModel())
}
