//
//  GroupNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI
import Kingfisher

struct GroupNotificationToast: View {
    
    var type: GROUP_TOAST_TYPES
    var content: String
    var metadata: NotificationMetadata
    
    init(content: String, metadata: NotificationMetadata) {
        self.type = GROUP_TOAST_TYPES(rawValue: metadata.type) ?? .applicationStatus
        self.content = content
        self.metadata = metadata
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
    
    var timestamp: Int {
        guard let time = metadata.timestamp else {
            return Int(Date.now.timeIntervalSince1970)
        }
        return time
    }
    
    let size: CGFloat = 40
    
    @State private var groupImageFailed = false
    
    
    var body: some View {
        Group {
            switch type {
            case .newApplication:
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
                            groupImageFailed = true
                        }
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                        .overlay {
                            if groupImageFailed {
                                Circle()
                                    .frame(width: size, height: size)
                                    .overlay {
                                        Image(systemName: "person.3.fill")
                                            .imageScale(.small)
                                            .foregroundStyle(Color.foreground)
                                    }
                            }
                        }
                    
                    
                    Group {
                        Text("[\(groupName)] \(username)")
                            .fontWeight(.bold)
                        +
                        Text(" applied to your club.")
                    }.frame(minHeight: 40)
                    
                    Spacer()
                }
            case .applicationStatus, .newReport:
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
                            groupImageFailed = true
                        }
                        .cacheOriginalImage()
                        .setProcessor(postUserImageNotificationProcessor())
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: size, height: size)
                        .overlay {
                            if groupImageFailed {
                                Circle()
                                    .frame(width: size, height: size)
                                    .overlay {
                                        Image(systemName: "person.3.fill")
                                            .imageScale(.small)
                                            .foregroundStyle(Color.foreground)
                                    }
                            }
                        }
                    
                    
                    Group {
                        Text("[\(groupName)]")
                            .fontWeight(.bold)
                        +
                        Text(" accepted your applciation")
                    }.frame(minHeight: 40)
                    
                    Spacer()
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(userId: UUID().uuidString,  username: "johndoe", postId: UUID().uuidString, groupName: "SLCFC", eventName: "Sunday PickUp", eventImageURL: "event-images/soccer-0.jpg", timestamp: 1725008123)
    GroupNotificationToast(content: "Check out 6 events happening in your area that you might enjoy!", metadata: metadata)
}
