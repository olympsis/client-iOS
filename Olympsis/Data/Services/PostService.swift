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
import FirebaseAuth

class PostService {
    
    private var http: Courrier
    
    init() {
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func getPosts(id: String, parentId: String?) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        var endpoint = Endpoint("/v1/posts", queryItems: [
            URLQueryItem(name: "groupID", value: id),
        ])
        if (parentId != nil) {
            endpoint = Endpoint("/v1/posts", queryItems: [
                URLQueryItem(name: "groupID", value: id),
                URLQueryItem(name: "parentID", value: parentId)
            ])
        }
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
    
    func getPost(id: String) async throws -> (Data) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
        return data
    }
    
    func createPost(post: PostDTO) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(post), headers: ["Authorization": token ?? ""])
    }
    
    func deletePost(postID: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts/\(postID)")
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func addLike(id: String, like: LikeDao) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts/\(id)/likes")
        return try await http.Request(.POST, endpoint, body: EncodeToData(like), headers: [
            "Authorization": token ?? ""
        ])
    }
    
    func removeLike(id: String, likeID: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts/\(id)/likes/\(likeID)")
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
        return resp
    }
    
    func addComment(id: String, comment: CommentDao) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts/\(id)/comments")
        
        return try await http.Request(.POST, endpoint, body: EncodeToData(comment), headers: [
            "Authorization": token ?? ""
        ])
    }
    
    func deleteComment(id: String, cid: String) async throws -> URLResponse {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/posts/\(id)/comments/\(cid)")
        
        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: ["Authorization": token ?? ""])
        return resp
    }
}

