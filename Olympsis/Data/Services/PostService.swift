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
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key, token: tokenStore.fetchTokenFromKeyChain())
    }
    
    func getPosts(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/posts", queryItems: [
            URLQueryItem(name: "clubId", value: id),
        ])
        
        return try await http.Request(endpoint: endpoint, method: Hermes.Method.GET)
    }
    
    func createPost(post: PostDao) async throws -> Data {
        let endpoint = Endpoint(path: "/posts", queryItems: [URLQueryItem]())
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: Hermes.Method.POST, body: EncodeToData(post))
        return data
    }
    
    func deletePost(postId: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/posts/\(postId)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Hermes.Method.DELETE)
        return resp
    }
    
    func getComments(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/posts/\(id)/comments", queryItems: [URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: Hermes.Method.GET)
    }
    
    func addComment(id: String, dao:CommentDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/posts/\(id)/comments", queryItems: [URLQueryItem]())
        
        return try await http.Request(endpoint: endpoint, method: Hermes.Method.POST, body: EncodeToData(dao))
    }
    
    func deleteComment(id: String, cid: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/posts/\(id)/comments/\(cid)", queryItems: [URLQueryItem]())
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Hermes.Method.DELETE)
        return resp
    }
}

