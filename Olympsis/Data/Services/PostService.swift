//
//  PostService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import os
import Hermes
import SwiftUI
import Foundation

class PostService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host)
    }
    
    func getPosts(id: String, parentId: String?) async throws -> (Data, URLResponse) {
        var endpoint = Endpoint("/posts", queryItems: [
            URLQueryItem(name: "groupID", value: id),
        ])
        if (parentId != nil) {
            endpoint = Endpoint("/posts", queryItems: [
                URLQueryItem(name: "groupID", value: id),
                URLQueryItem(name: "parentID", value: parentId)
            ])
        }
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getPost(id: String) async throws -> (Data) {
        let endpoint = Endpoint("/posts/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return data
    }
    
    func createPost(post: PostDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/posts")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(post), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func deletePost(postID: String) async throws -> URLResponse {
        let endpoint = Endpoint("/posts/\(postID)")
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func addLike(id: String, like: LikeDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/posts/\(id)/likes")
        return try await http.Request(.POST, endpoint, body: EncodeToData(like), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
    }
    
    func removeLike(id: String, likeID: String) async throws -> URLResponse {
        let endpoint = Endpoint("/posts/\(id)/likes/\(likeID)")
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func addComment(id: String, comment: CommentDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/posts/\(id)/comments")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(comment), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
    }
    
    func deleteComment(id: String, cid: String) async throws -> URLResponse {
        let endpoint = Endpoint("/posts/\(id)/comments/\(cid)")
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
}

