//
//  NewPostManager.swift
//  Olympsis
//
//  Created by Joel on 1/27/24.
//

import os
import SwiftUI
import Foundation
import _PhotosUI_SwiftUI

class NewPostViewModel: ObservableObject {
    
    @Published var type: POST_TYPE
    @Published var body: String = ""
    
    @Published var selectedEvent: Event? = nil
    @Published var selectedImages: [UIImage] = [] {
        didSet {
            for image in selectedImages {
                if let data = image.jpegData(compressionQuality: 0.5) {
                    selectedImagesData.append(data)
                } else {
                    log.error("Failed to convert UIImage to jpeg data")
                }
            }
        }
    }
    @Published var selectedImagesData: [Data] = []
    @Published var externalLink: String = ""
    
    @Published var showImageContentError: Bool = false
    
    @Published var status: LOADING_STATE = .pending
    
    var postObserver = PostObserver()
    var uploadObserver = UploadObserver()
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "new_post_view_model")
    
    init(type: POST_TYPE = .Post) {
        self.type = type
    }
    
    /**
     Creates a post object on Olympsis
     - Parameters:
        - groupId: the id of the group to create the post in
     - Returns:
        an optional `Post` object in case we fail to create the post
     */
    func createPost(groupId: String, user: User) async throws -> Post? {
        
        await MainActor.run {
            self.status = .loading
        }
        
        // generate post object data transfer object
        guard var dto = generateNewPostData(groupId: groupId) else {
            handleFailure()
            return nil
        }
        
        // upload images
        if (!selectedImagesData.isEmpty) {
            
            let imageResponses = try await withThrowingTaskGroup(of: ImageUploadResponse?.self) { group -> [ImageUploadResponse] in
                for data in selectedImagesData {
                    group.addTask {
                        await self.uploadImage(data: data)
                    }
                }
                
                let tasks = try await group.reduce(into: [ImageUploadResponse]()) {
                    if let resp = $1 {
                        if resp.score > 4 {                            
                            throw MediaUploadError.innapropriateContent
                        }
                        if resp.score > 3 {
                            dto.isSensitive = true
                        }
                        $0.append(resp)
                    }
                }
                return tasks
            }
            
            // when images are done being uploaded we continue with the post creation
            var images: [String] = []
            for res in imageResponses {
                if let url = res.url {
                    images.append(url.replacingOccurrences(of: "olympsis-", with: ""))
                }
            }
            
            dto.images = images
            
            // make the http call to create post
            guard let postId = await postObserver.createPost(dto: dto) else {
                log.error("Deleting post images..")
                if let images = dto.images {
                    await deleteImages(images: images)
                }
                handleFailure()
                return nil
            }
            
            // generate a post object locally
            guard let post = generateNewPost(id: postId, user: user, dto: dto) else {
                log.error("Failed to generate post locally")
                handleFailure()
                return nil
            }
            
            DispatchQueue.main.async {
                self.status = .success
            }
            
            return post
        } else {
            
            // make the http call to create post
            guard let postId = await postObserver.createPost(dto: dto) else {
                handleFailure()
                return nil
            }
            
            // generate a post object localy
            guard let post = generateNewPost(id: postId, user: user, dto: dto) else {
                log.error("Failed to generate post locally")
                handleFailure()
                return nil
            }
            
            DispatchQueue.main.async {
                self.status = .success
            }
            return post
        }
    }
    
    /**
     Just a function to handle displaying to the user that the action has failed
     */
    private func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.status = .pending
        }
    }
    
    /**
     Generates a `PostDTO` object to send new post to the backend.
     
     Contains guards against the body contents to make sure that we have a reasonably sized body before creating transfer object
     
     - Parameters:
        - groupId: the string id of the group to create the post in
     - Returns:
        an optional `PostDTO` object to manipulate before sending to backend
     */
    func generateNewPostData(groupId: String) -> PostDTO? {
        guard
            !body.isEmpty,
            body != "Write a caption",
            body.count > 5 else {
            return nil
        }
        return PostDTO(
            type: self.type.rawValue,
            groupID: groupId,
            body: self.body,
            externalLink: !self.externalLink.isEmpty ? self.externalLink : nil
        )
    }
    
    /**
     Generates a post object on the client side to put in the feed
     
     We have some checks to make sure we have good user data before generating the post object
     
     - Parameters:
        - id: the unique id of the post object
        - user: poster information
        - dto: data transfer object of the post
     - Returns:
        an optional `Post`object if the user data is valid
     */
    func generateNewPost(id: String, user: User, dto: PostDTO) -> Post? {
        guard let uuid = user.uuid,
              let username = user.username else {
                  return nil
              }
        let snippet = UserSnippet(uuid: uuid, username: username, imageURL: user.imageURL)
        return Post(
            id: id,
            type: dto.type ?? "post",
            poster: snippet,
            body: dto.body ?? "",
            event: nil,
            images: dto.images,
            likes: [Reaction](),
            comments: [Comment](),
            externalLink: dto.externalLink,
            isSensitive: false,
            createdAt: Date()
        )
    }
    
    /**
     Handles uploading an image to bucket
     - Parameters:
        - data: image data to upload
     */
    func uploadImage(data: Data?) async -> ImageUploadResponse? {
        // image unique id
        let imageId = UUID().uuidString
        
        guard let d = data else {
            log.error("Failed to find image data: \(imageId)")
            return nil
        }
        
        guard let response = await uploadObserver.UploadImage(location: "/olympsis-feed-images", fileName: imageId, data: d) else {
            log.error("Failed to upload image: \(imageId)")
            return nil
        }
        return response
    }
    
    /**
     Handles deleting images from a bucket
     - Parameters:
        - images: an array of strings containing the name of the name of the images to delete
     */
    func deleteImages(images: [String]) async {
        for image in images {
            let resp = await uploadObserver.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(image))
            if !resp {
                log.error("Failed to delete image: \(image)")
            }
        }
    }
}
