//
//  FeedViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/23/24.
//

import os
import Foundation

class FeedViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var status: LOADING_STATE = .pending
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "feed_view_model")
    
    @MainActor
    func getLatestPosts(session: SessionStore) async {
        status = .loading
        // this error should never happen but you never know :)
        guard let selectedGroup = session.selectedGroup else {
            status = .failure
            return
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
                status = .failure
                log.error("Failed to get selected group")
                return
            }
            guard let response: [Post] = await session.postObserver.getPosts(clubId: club.id ?? "", parentId: club.parent?.id) else {
                status = .failure
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
            self.posts.append(contentsOf: sorted)
        } else {
            guard let org = selectedGroup.organization else {
                status = .failure
                log.error("Failed to get selected group")
                return
            }
            guard let response: [Post] = await session.postObserver.getPosts(clubId: org.id ?? "", parentId: nil) else {
                status = .failure
                log.error("Failed to get response from posts query")
                return
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
            self.posts.append(contentsOf: sorted)
        }
    }
}
