//
//  PostNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI
import Kingfisher

struct PostNotificationToast: View {
    
    var metadata: NotificationMetadata
    
    private var content: String {
        switch metadata.type {
        case .newPost:
            return "created a new post!"
        default:
            return metadata.type == .postLike ? "liked your post!" : "left a comment on your post!"
        }
    }
    
    private var imageURL: URL? {
        if let userImage = metadata.userImageURL {
            return generateImageURL(userImage)
        }
        return nil
    }
    
    private var groupName: String {
        guard let groupName = metadata.groupName else {
            return "olympsis"
        }
        return groupName
    }
    
    private var username: String {
        guard let username = metadata.username else {
            return "olympsis-user"
        }
        return username
    }
    
    private var postImageURL: URL? {
        guard let postImg = metadata.postImageURL else {
            return nil
        }
        return generateImageURL(postImg)
    }
    
    private let size: CGFloat = 40
    
    var body: some View {
        Group {
            switch metadata.type {
            case .newPost:
                HStack(alignment: .center, spacing: 10) {
                    KFImage(imageURL)
                        .placeholder({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(.white)
                                .overlay {
                                    ProgressView()
                                }
                        })
                        .onFailureView({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(Color.Background.tertiary)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(Color.gray)
                                }
                        })
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                    
                    HStack(alignment: .bottom) {
                        Group {
                            Text("[\(groupName)] ")
                                .fontWeight(.bold)
                            +
                            Text(username)
                                .fontWeight(.medium)
                            +
                            Text(" \(content)")
                        }
                        .font(.callout)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                    
                    if postImageURL != nil {
                        KFImage(postImageURL)
                            .cacheOriginalImage()
                            .setProcessor(postImageNotificationProcessor())
                            .resizable()
                            .onFailureView({
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.Background.tertiary)
                                    .overlay {
                                        Image(systemName: "photo.fill")
                                            .foregroundStyle(Color.gray)
                                    }
                            })
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: size, height: size+10)
                    }
                }
            default: // Like | Coment
                HStack(alignment: .center, spacing: 10) {
                    KFImage(imageURL)
                        .placeholder({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(.white)
                                .overlay {
                                    ProgressView()
                                }
                        })
                        .onFailureView({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(Color.Background.tertiary)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(Color.gray)
                                }
                        })
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                    
                    HStack(alignment: .bottom) {
                        Group {
                            Text("[\(groupName)] ")
                                .fontWeight(.bold)
                            +
                            Text(username)
                                .fontWeight(.medium)
                            +
                            Text(" \(content)")
                        }
                        .font(.callout)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                    
                    if postImageURL != nil {
                        KFImage(postImageURL)
                            .cacheOriginalImage()
                            .setProcessor(postImageNotificationProcessor())
                            .resizable()
                            .onFailureView({
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.Background.tertiary)
                                    .overlay {
                                        Image(systemName: "photo.fill")
                                            .foregroundStyle(Color.gray)
                                    }
                            })
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: size, height: size+10)
                    }
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .newPost, userID: UUID().uuidString, username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC")
    let newPostData = NotificationMetadata(type: .postLike, userID: UUID().uuidString, username: "janedoe", postID: UUID().uuidString, groupName: "SLCFC")
    let newCommentData = NotificationMetadata(type: .postComment, userID: UUID().uuidString, username: "janedoe", postID: UUID().uuidString, groupName: "International Soccer")
    
    RoundedRectangle(cornerRadius: 10)
        .frame(height: 60)
        .padding(.horizontal, 10)
        .foregroundStyle(Color.Background.secondary)
        .overlay {
            PostNotificationToast(metadata: metadata)
        }
}
