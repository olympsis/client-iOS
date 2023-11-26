//
//  GroupViewModel.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import Foundation

class GroupViewModel: ObservableObject {
    
    @Published var selectedGroup: GroupSelection?
    @Published var groups = [GroupSelection]()
    @Published var posts: [Post] = [Post]()
    @Published var postsCache: [UUID:[Post]] = [:]
    
    
    func changeSelectedGroup(newGroup: GroupSelection) {
        // if there isn't a selected group yet just set it
        guard let oldGroup = selectedGroup else {
            selectedGroup = newGroup
            return
        }
        
        // cache old posts
        guard let posts = oldGroup.posts else {
            selectedGroup = newGroup
            return
        }
        cachePosts(id: oldGroup.id, posts: posts)
        
        // set new group & fetch posts
        selectedGroup = newGroup
        guard let cachedPosts = fetchPosts(id: newGroup.id) else {
            return
        }
        self.posts = cachedPosts
    }
    
    func cachePosts(id: UUID, posts: [Post]) {
        postsCache[id] = posts
    }
    
    func fetchPosts(id: UUID) -> [Post]? {
        return postsCache[id]
    }
}
