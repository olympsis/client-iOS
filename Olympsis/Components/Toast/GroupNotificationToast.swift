//
//  GroupNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI
import Kingfisher

struct GroupNotificationToast: View {
    
    var metadata: NotificationMetadata
    private var content: String {
        switch metadata.type {
        case .newClubApplication:
            return " applied to your club."
        case .clubApplicationUpdate:
            return "Your application was approved!"
        case .clubExpulsion:
            return "You've been kicked out of the club."
        case .clubSuspension:
            return "You've been suspended for 24 hours."
        default:
            return "Your rank has changed."
        }
    }
    
    var imageURL: URL? {
        if let groupImage = metadata.groupImageURL {
            return generateImageURL(groupImage)
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
    
    let size: CGFloat = 40
    
    var body: some View {
        Group {
            switch metadata.type {
            case .newClubApplication:
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
                        .onFailureView({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(Color.Background.tertiary)
                                .overlay {
                                    Image(systemName: "person.3.fill")
                                        .imageScale(.small)
                                        .foregroundStyle(Color.gray)
                                }
                        })
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                    
                    Group {
                        Text("[\(groupName)] \(username)")
                            .fontWeight(.bold)
                        +
                        Text(content)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                }
            default:
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
                        .onFailureView({
                            Circle()
                                .frame(width: size, height: size)
                                .foregroundStyle(Color.Background.tertiary)
                                .overlay {
                                    Image(systemName: "person.3.fill")
                                        .imageScale(.small)
                                        .foregroundStyle(Color.gray)
                                }
                        })
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                    
                    
                    Group {
                        Text("[\(groupName)]")
                            .fontWeight(.bold)
                        +
                        Text(" \(content)")
                    }.frame(minHeight: 40)
                    
                    Spacer()
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .newClubApplication, userID: UUID().uuidString,  username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC", eventImageURL: "event-images/soccer-0.jpg")
    
    let status = NotificationMetadata(type: .clubApplicationUpdate, userID: UUID().uuidString,  username: "janedoe", postID: UUID().uuidString, groupName: "SLCFC", eventImageURL: "event-images/soccer-0.jpg")
    
    RoundedRectangle(cornerRadius: 10)
        .frame(height: 60)
        .padding(.horizontal, 10)
        .foregroundStyle(Color.Background.secondary)
        .overlay {
            GroupNotificationToast(metadata: status)
        }
}
