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

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func getPosts(id: String, parentId: String?) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        var queries = [URLQueryItem(name: "groupID", value: id)]
        if (parentId != nil && !parentId!.isEmpty) {
            queries.append(URLQueryItem(name: "parentID", value: parentId))
        }
        let endpoint = Endpoint("/v1/posts", queryItems: queries)
        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getPost(id: String) async throws -> (Data) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts/\(id)")
        let (data, _) = try await http.Request(.GET, endpoint, headers: headers)
        return data
    }

    func createPost(post: PostDTO) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts")

        return try await http.Request(.POST, endpoint, body: EncodeToData(post), headers: headers)
    }

    func deletePost(postID: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts/\(postID)")

        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return resp
    }

    func addLike(id: String, like: ReactionDao) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts/\(id)/likes")
        return try await http.Request(.POST, endpoint, body: EncodeToData(like), headers: headers)
    }

    func removeLike(id: String, likeID: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts/\(id)/likes/\(likeID)")

        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return resp
    }

    func addComment(id: String, comment: CommentDao) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts/\(id)/comments")

        return try await http.Request(.POST, endpoint, body: EncodeToData(comment), headers: headers)
    }

    func deleteComment(id: String, cid: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/posts/\(id)/comments/\(cid)")

        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return resp
    }
}
