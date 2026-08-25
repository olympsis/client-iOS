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

/// Network calls for the posts endpoints — feed posts, likes, and comments.
/// The shared `APIService` plumbing handles auth headers and the >500 catch;
/// endpoint-specific status meanings (e.g. 204 = "no posts") are handled here.
class PostService: APIService {

    let http: Courrier
    let decoder = JSONDecoder()
    private let log = Logger(subsystem: "com.olympsis.client", category: "post_service")

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    /// GET /v1/posts?groupID=&parentID=
    ///
    /// 204 means "no posts for this group" — a valid, empty result, not a
    /// failure. Any other status outside the 2xx range returns nil.
    /// - Parameter clubId: the club/org id to fetch posts for (sent as `groupID`)
    /// - Parameter parentId: optional parent org id, sent as `parentID` when non-empty
    /// - Returns: the group's posts, `[]` on 204, or nil on failure
    func getPosts(clubId: String, parentId: String?) async -> [Post]? {
        var queries = [URLQueryItem(name: "groupID", value: clubId)]
        if let parentId = parentId, !parentId.isEmpty {
            queries.append(URLQueryItem(name: "parentID", value: parentId))
        }
        do {
            let (data, statusCode) = try await requestRaw(.GET, Endpoint("/v1/posts", queryItems: queries))
            guard statusCode < 300 else {
                return nil
            }
            if statusCode == 204 {
                return [Post]()
            }
            let object = try decoder.decode(PostsResponse.self, from: data)
            return object.posts
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// GET /v1/posts/{id}
    ///
    /// Deliberately does not check the status code — decode-or-nil, matching
    /// the endpoint's original behavior.
    /// - Parameter id: the post's id
    /// - Returns: the post, or nil if the response couldn't be decoded
    func getPost(id: String) async -> Post? {
        do {
            let (data, _) = try await requestRaw(.GET, Endpoint("/v1/posts/\(id)"))
            let object = try decoder.decode(Post.self, from: data)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// POST /v1/posts/{id}/likes
    /// - Returns: the new like's id, or nil on any failure
    func addLike(id: String, like: ReactionDao) async -> String? {
        do {
            let object: CreateResponse = try await request(.POST, Endpoint("/v1/posts/\(id)/likes"), body: EncodeToData(like))
            return object.id
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// DELETE /v1/posts/{id}/likes/{likeID}
    func deleteLike(id: String, likeID: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/posts/\(id)/likes/\(likeID)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// POST /v1/posts
    ///
    /// Builds the `PostDTO` from loose fields before sending — the server
    /// owns `id`/`createdAt`. Returns the full `CreateResponse`.
    func createPost(type: String, owner: String, groupId: String, eventID: String? = nil, body: String, images: [String]? = nil, externalLink: String? = nil) async -> CreateResponse? {
        let post = PostDTO(type: type, poster: owner, groupID: groupId, body: body, eventID: eventID, images: images, externalLink: externalLink, createdAt: nil)
        do {
            return try await request(.POST, Endpoint("/v1/posts"), body: EncodeToData(post), expecting: 201)
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// POST /v1/posts
    ///
    /// Same endpoint as above for a caller that already has a `PostDTO` —
    /// returns just the new post's id.
    func createPost(dto: PostDTO) async -> String? {
        do {
            let object: CreateResponse = try await request(.POST, Endpoint("/v1/posts"), body: EncodeToData(dto), expecting: 201)
            return object.id
        } catch {
            log.error("Failed to create post: \(error)")
        }
        return nil
    }

    /// DELETE /v1/posts/{postID}
    func deletePost(postID: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/posts/\(postID)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }

    /// POST /v1/posts/{id}/comments
    ///
    /// Tri-state: true on success, false on a non-200 response, nil if the
    /// request itself threw (network failure, etc).
    func addComment(id: String, comment: CommentDao) async -> Bool? {
        do {
            let (_, statusCode) = try await requestRaw(.POST, Endpoint("/v1/posts/\(id)/comments"), body: EncodeToData(comment))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// DELETE /v1/posts/{id}/comments/{cid}
    func deleteComment(id: String, cid: String) async -> Bool {
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, Endpoint("/v1/posts/\(id)/comments/\(cid)"))
            guard statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
}
