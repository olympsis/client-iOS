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
    
    func getPosts(clubId: String) async -> [Post] {
        do {
            let (data, res) = try await postService.getPosts(id: clubId)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return [Post]()
            }
            let object = try decoder.decode(PostsResponse.self, from: data)
            return object.posts
        } catch {
            log.error("\(error)")
        }
        return [Post]()
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
    
    func addLike(id: String, like: Like) async -> Like? {
        do {
            let res = try await postService.addLike(id: id, like: like)
            let object = try decoder.decode(Like.self, from: res)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
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
    
    func createPost(owner: String, clubId: String, body: String, images:[String]?=nil) async -> Post? {
        do {
            let post = Post(id: nil, poster: owner, clubID: clubId, body: body, images: images, data: nil, likes: nil, comments: nil, createdAt: nil)
            let res = try await postService.createPost(post: post)
            let object = try decoder.decode(Post.self, from: res)
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
    
    func addComment(id: String, comment: Comment) async -> Comment? {
        do {
            let (data, res) = try await postService.addComment(id: id, comment: comment)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(Comment.self, from: data)
            return object
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
