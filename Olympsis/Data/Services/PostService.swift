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
    private let tokenStore = SecureStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key)
    }
    
    func getPosts(id: String, parentId: String?) async throws -> (Data, URLResponse) {
        var endpoint = Endpoint(path: "/posts", queryItems: [
            URLQueryItem(name: "groupID", value: id),
        ])
        if (parentId != nil) {
            endpoint = Endpoint(path: "/posts", queryItems: [
                URLQueryItem(name: "groupID", value: id),
                URLQueryItem(name: "parentID", value: parentId)
            ])
        }
        
        return try await http.Request(endpoint: endpoint, method: Hermes.Method.GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    func getPost(id: String) async throws -> (Data) {
        let endpoint = Endpoint(path: "/posts/\(id)")
        let (data, _) = try await http.Request(endpoint: endpoint, method: Hermes.Method.GET, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return data
    }
    
    func createPost(post: Post) async throws -> Data {
        let endpoint = Endpoint(path: "/posts")
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: Hermes.Method.POST, body: EncodeToData(post), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return data
    }
    
    func deletePost(postID: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/posts/\(postID)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Hermes.Method.DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func addLike(id: String, like: Like) async throws -> (Data) {
        let endpoint = Endpoint(path: "/posts/\(id)/likes")
        let (data, _) = try await http.Request(endpoint: endpoint, method: Hermes.Method.POST, body: EncodeToData(like), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
        return data
    }
    
    func removeLike(id: String, likeID: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/posts/\(id)/likes/\(likeID)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Hermes.Method.DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
    
    func addComment(id: String, comment: Comment) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/posts/\(id)/comments")
        
        return try await http.Request(endpoint: endpoint, method: Hermes.Method.POST, body: EncodeToData(comment), headers: [
            "Authorization": tokenStore.fetchTokenFromKeyChain()
        ])
    }
    
    func deleteComment(id: String, cid: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/posts/\(id)/comments/\(cid)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Hermes.Method.DELETE, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
        return resp
    }
}

