//
//  FeedViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/23/24.
//

import os
import Foundation

class FeedViewModel: ObservableObject {
    
    @Published var posts: [String : [Post]] = [:]
    @Published var status: LOADING_STATE = .pending
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "feed_view_model")
    
    @MainActor
    func getLatestPosts(session: SessionStore, refresh: Bool = false) async {
        if !refresh {
            status = .loading
        }
        // this error should never happen but you never know :)
        guard let selectedGroup = session.groupsManager.selected else {
            if !refresh {
                status = .failure
            }
            return
        }
        
        // sorting condition for posts.
        // if the parent org has a pinned post that take priority #1
        // if the club has a pinned post then that takes priority #2
        // then the rest of the posts are sorted by when they were created
        let condition: (Post, Post) -> Bool = { p, p2 in
            return p.createdAt > p2.createdAt
        }
        
        // make query to backend for posts
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                if !refresh {
                    status = .failure
                }
                log.error("Failed to get selected group")
                return
            }
            guard let response: [Post] = await session.postService.getPosts(clubId: club.id, parentId: club.parent?.id) else {
                if !refresh {
                    status = .failure
                }
                log.error("Failed to get response from posts query")
                return
            }
            
            var pinned = [Post]()
            var sorted = response.sorted(by: condition)
            
            if let parent = club.parent,
                let pinnedPosts = parent.pinnedPosts {
                if let resp = sorted.first(where: { val in pinnedPosts.contains(where: { val.id == $0 })}) {
                    pinned.append(resp)
                }
            }
            if let resp = sorted.first(where: { club.pinnedPosts.contains($0.id) }) {
                pinned.append(resp)
            }
            
            sorted.removeAll { p in
                pinned.contains(where: { $0.id == p.id })
            }
            
            for (index, element) in pinned.enumerated() {
                sorted.insert(element, at: index)
            }
            if !refresh {
                status = .success
            }
            self.posts[club.id] = sorted
        } else {
            guard let org = selectedGroup.organization else {
                if !refresh {
                    status = .failure
                }
                log.error("Failed to get selected group")
                return
            }
            guard let response: [Post] = await session.postService.getPosts(clubId: org.id, parentId: nil) else {
                if !refresh {
                    status = .failure
                }
                log.error("Failed to get response from posts query")
                return
            }
            
            var pinned = [Post]()
            var sorted = response.sorted(by: condition)
            
            if let org = selectedGroup.organization {
                if let resp = sorted.first(where: { post in
                    return org.pinnedPosts.contains(where: { $0 == post.id })
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
            if !refresh {
                status = .success
            }
            self.posts[org.id] = sorted
        }
    }
    
    @MainActor
    func loadMorePosts(session: SessionStore, batch: Int=20) async {
        guard session.groupsManager.selected != nil else {
            return
        }
    }
}
