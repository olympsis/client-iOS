//
//  PostObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class PostObserver: ObservableObject{
    private let decoder: JSONDecoder
    private let postService: PostService
    
    init(){
        decoder = JSONDecoder()
        postService = PostService()
    }
    
    func fetchPosts(clubId: String) async -> [Post]{
        do {
            let (data, res) = try await postService.getPosts(id: clubId)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return [Post]()
            }
            let object = try decoder.decode(PostsResponse.self, from: data)
            return object.posts
        } catch (let err) {
            print(err)
        }
        return [Post]()
    }
    
    func createPost(owner: String, clubId: String, body: String, images:[String]?=nil) async -> Post? {
        do {
            let dao = PostDao(owner: owner, clubId: clubId, body: body, images: images)
            let res = try await postService.createPost(post: dao)
            let object = try decoder.decode(Post.self, from: res)
            return object
        } catch {
            print(error)
        }
        return nil
    }
    
    func deletePost(postId: String) async -> Bool {
        do {
            let res = try await postService.deletePost(postId: postId)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func getComments(id: String) async -> [Comment]{
        do {
            let (data, res) = try await postService.getComments(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return [Comment]()
            }
            let object = try decoder.decode(CommentsResponse.self, from: data)
            return object.comments
        } catch {
            print(error)
        }
        return [Comment]()
    }
    
    func addComment(id: String, dao: CommentDao) async -> Bool {
        do {
            let (_, res) = try await postService.addComment(id: id, dao: dao)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func deleteComment(id: String, cid: String) async -> Bool {
        do {
            let res = try await postService.deleteComment(id: id, cid: cid)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
    }
}
