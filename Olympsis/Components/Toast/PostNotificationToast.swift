//
//  PostNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI
import Kingfisher

struct PostNotificationToast: View {
    
    var type: POST_TOAST_TYPES
    var content: String
    var metadata: NotificationMetadata
    
    init(content: String, metadata: NotificationMetadata) {
        self.type = POST_TOAST_TYPES(rawValue: metadata.type) ?? .like
        self.content = content
        self.metadata = metadata
    }
    
    var imageURL: URL? {
        if let userImage = metadata.userImageURL {
            return generateImageURL(userImage)
        }
        return nil
    }
    
    var groupName: String {
        guard let groupName = metadata.groupName else {
            return "olympsis"
        }
        return groupName
    }
    
    var username: String {
        guard let username = metadata.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var postImageURL: URL? {
        guard let postImg = metadata.postImageURL else {
            return nil
        }
        return generateImageURL(postImg)
    }
    
    var timestamp: Int {
        guard let time = metadata.timestamp else {
            return Int(Date.now.timeIntervalSince1970)
        }
        return time
    }
    
    
    let size: CGFloat = 40
    
    @State private var postImageFailed = false
    @State private var profileImageFailed = false
    
    var body: some View {
        Group {
            switch type {
            case .newPost:
                HStack(alignment: .top, spacing: 10) {
                    KFImage(imageURL)
                        .placeholder({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(.white)
                                .overlay {
                                    ProgressView()
                                }
                        })
                        .onFailure { _ in
                            profileImageFailed = true
                        }
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                        .overlay {
                            if profileImageFailed {
                                Circle()
                                    .frame(width: size, height: size)
                                    .foregroundStyle(Color.Background.primary)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundStyle(Color.foreground)
                                    }
                            }
                        }
                    
                    HStack(alignment: .bottom) {
                        Group {
                            Text("[\(groupName)]")
                            +
                            Text(username)
                                .fontWeight(.bold)
                            +
                            Text(" \(content)")
                        }
                        .font(.callout)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                    
                    KFImage(postImageURL)
                        .cacheOriginalImage()
                        .setProcessor(postImageNotificationProcessor())
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: size, height: size)
                }
            case .like, .comment:
                HStack(alignment: .top, spacing: 10) {
                    KFImage(imageURL)
                        .placeholder({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(.white)
                                .overlay {
                                    ProgressView()
                                }
                        })
                        .onFailure { _ in
                            profileImageFailed = true
                        }
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                        .overlay {
                            if profileImageFailed {
                                Circle()
                                    .frame(width: size, height: size)
                                    .foregroundStyle(Color.Background.primary)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundStyle(Color.foreground)
                                    }
                            }
                        }
                    
                    HStack(alignment: .bottom) {
                        Group {
                            Text("[\(groupName)] ")
                            +
                            Text(username)
                                .fontWeight(.bold)
                            +
                            Text(" \(content)")
                        }
                        .font(.callout)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                    
                    KFImage(postImageURL)
                        .cacheOriginalImage()
                        .setProcessor(postImageNotificationProcessor())
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: size, height: size)
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(userId: UUID().uuidString, username: "johndoe", postId: UUID().uuidString, groupName: "SLCFC", timestamp: 1725008123)
    PostNotificationToast(content: "liked your post", metadata: metadata)
}
