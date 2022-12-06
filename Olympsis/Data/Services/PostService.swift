//
//  PostService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import os
import SwiftUI
import Foundation

class PostService: Service {
    
    var log: Logger
    var http: HttpService
    
    init() {
        self.log = Logger()
        self.http = HttpService()
    }
    
    let urlSession = URLSession.shared
    
    func getPosts(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/posts", queryItems: [
            URLQueryItem(name: "clubId", value: id),
        ])
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.GET)
    }
    
    func createPost(post: PostDao) async throws -> Data {
        let endpoint = Endpoint(path: "/v1/posts", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: Method.POST, body: post)
        return data
    }
    
    func deletePost(postId: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/posts/\(postId)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.DELETE)
        return resp
    }
    
    func getComments(id: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/posts/\(id)/comments", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(GET): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.GET)
    }
    
    func addComment(id: String, dao:CommentDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint(path: "/v1/posts/\(id)/comments", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(POST): \(endpoint.path)")
        
        return try await http.Request(endpoint: endpoint, method: Method.POST, body: dao)
    }
    
    func deleteComment(id: String, cid: String) async throws -> URLResponse {
        let endpoint = Endpoint(path: "/v1/posts/\(id)/comments/\(cid)", queryItems: [URLQueryItem]())
        
        log.log("Initiating request to server(DELETE): \(endpoint.path)")
        
        let (_, resp) = try await http.Request(endpoint: endpoint, method: Method.DELETE)
        return resp
    }
}

