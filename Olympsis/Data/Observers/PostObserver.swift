//
//  PostObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import os
import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class PostObserver: ObservableObject{
    private let decoder = JSONDecoder()
    private let postService = PostService()
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "post_observer")
    
    func getPosts(clubId: String, parentId: String?) async -> [Post]? {
        do {
            let (data, res) = try await postService.getPosts(id: clubId, parentId: parentId ?? "")
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(PostsResponse.self, from: data)
            return object.posts
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func getPost(id: String) async -> Post? {
        do {
            let data = try await postService.getPost(id: id)
            let object = try decoder.decode(Post.self, from: data)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func addLike(id: String, like: LikeDao) async -> String? {
        do {
            let (data, res) = try await postService.addLike(id: id, like: like)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(CreateResponse.self, from: data)
            return object.id
        } catch {
            log.error("\(error)")
            return nil
        }
    }
    
    func deleteLike(id: String, likeID: String) async -> Bool {
        do {
            let res = try await postService.removeLike(id: id, likeID: likeID)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func createPost(type: String, owner: String, groupId: String, eventID: String?=nil, body: String, images:[String]?=nil, externalLink: String?=nil) async -> CreateResponse? {
        do {
            let post = PostDao(type: type, poster: owner, groupID: groupId, body: body, eventID: eventID, images: images, createdAt: nil, externalLink: externalLink)
            let (data, res) = try await postService.createPost(post: post)
            guard (res as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let object = try decoder.decode(CreateResponse.self, from: data)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func deletePost(postID: String) async -> Bool {
        do {
            let res = try await postService.deletePost(postID: postID)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func addComment(id: String, comment: CommentDao) async -> Bool? {
        do {
            let (_, res) = try await postService.addComment(id: id, comment: comment)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func deleteComment(id: String, cid: String) async -> Bool {
        do {
            let res = try await postService.deleteComment(id: id, cid: cid)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
}
