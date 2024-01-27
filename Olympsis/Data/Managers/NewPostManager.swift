//
//  NewPostManager.swift
//  Olympsis
//
//  Created by Joel on 1/27/24.
//

import SwiftUI
import Foundation
import _PhotosUI_SwiftUI

class NewPostManager: ObservableObject {
    
    @Published var type: POST_TYPE
    @Published var body: String
    @Published var images: [String]?
    @Published var selectedEvent: Event?
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImageData: Data?
    @Published var externalLink: String
    @StateObject var uploadObserver = UploadObserver()
    
    init(type: POST_TYPE = .Post, body: String, images: [String]?=nil, selectedEvent: Event?=nil, selectedItem: PhotosPickerItem?=nil, selectedImageData: Data?=nil, externalLink: String) {
        self.type = type
        self.body = body
        self.images = images
        self.selectedEvent = selectedEvent
        self.selectedItem = selectedItem
        self.selectedImageData = selectedImageData
        self.externalLink = externalLink
    }
    
    convenience init (type: POST_TYPE = .Post) {
        self.init(type: type, body: "", externalLink: "")
    }
    
    func GenerateNewPostData(groupId: String) -> PostDao? {
        guard self.body != "" && self.body.count > 5 else {
            return nil
        }
        return PostDao(
            type: self.type.rawValue,
            groupID: groupId,
            body: self.body,
            images: self.images,
            externalLink: self.externalLink != "" ? self.externalLink : nil
        )
    }
    
    func GenerateNewPost(id: String, user: UserData, dao: PostDao) -> Post? {
        guard let uuid = user.uuid,
              let username = user.username else {
                  return nil
              }
        let snippet = UserSnippet(uuid: uuid, username: username, imageURL: user.imageURL)
        return Post(
            id: id,
            type: dao.type,
            poster: snippet,
            body: dao.body ?? "",
            images: dao.images,
            likes: nil,
            comments: nil,
            createdAt: Int(Date().timeIntervalSinceNow),
            externalLink: dao.externalLink
        )
    }
    
    func UploadImage(data: Data?) async -> String? {
        guard let d = data else {
            return nil
        }
        // new image
        let imageId = UUID().uuidString
        guard await uploadObserver.UploadImage(location: "/olympsis-feed-images", fileName: imageId, data: d) else {
            return nil
        }
        return "feed-images/\(imageId).jpeg"
    }
    
    func DeleteImages(images: [String]) async -> Bool {
        for image in images {
            _ = await uploadObserver.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(image))
        }
        return true
    }
}
