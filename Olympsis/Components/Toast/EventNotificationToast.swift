//
//  EventNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI
import Kingfisher

struct EventNotificationToast: View {
    
    var type: EVENT_TOAST_TYPES
    var content: String
    var metadata: NotificationMetadata
    
    init(content: String, metadata: NotificationMetadata) {
        self.type = EVENT_TOAST_TYPES(rawValue: metadata.type) ?? .eventStatus
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
    
    var eventName: String {
        guard let name = metadata.eventName else {
            return ""
        }
        return name
    }
    
    var eventImageURL: URL? {
        guard let postImg = metadata.eventImageURL else {
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
            case .newEvent:
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
                            Text(username)
                                .fontWeight(.bold)
                            +
                            Text(" \(content)")
                            +
                            Text(" \(eventName)")
                                .fontWeight(.bold)
                        }
                        .font(.callout)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                    
                    KFImage(eventImageURL)
                        .cacheOriginalImage()
                        .setProcessor(postImageNotificationProcessor())
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: size, height: size)
                }
            case .eventInvite:
                HStack(alignment: .top, spacing: 10) {
                    
                    KFImage(eventImageURL)
                        .cacheOriginalImage()
                        .setProcessor(postImageNotificationProcessor())
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: size, height: size)
                    
                    Group {
                        Text("You've been invited to ")
                            
                        +
                        Text("RSVP")
                            .italic()
                            .fontWeight(.bold)
                        +
                        Text(" to the ")
                        +
                        Text(eventName)
                            .fontWeight(.bold)
                        +
                        Text(" event")
                    }.frame(minHeight: 40)
                        
                    
                    Spacer()
                }
            case .eventsSummary:
                HStack(alignment: .top, spacing: 10) {
                    Group {
                        Text(content)
                    }.frame(minHeight: 40)
                        
                    
                    Spacer()
                }
            case .eventStatus:
                HStack(alignment: .top, spacing: 10) {
                    
                    KFImage(eventImageURL)
                        .cacheOriginalImage()
                        .setProcessor(postImageNotificationProcessor())
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: size, height: size)
                    
                    Group {
                        Text("\(eventName) ")
                            .fontWeight(.bold)
                        +
                        Text(content)
                    }.frame(minHeight: 40)
                        
                    
                    Spacer()
                }
            case .eventParticipantStatus:
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
                            Text(username)
                                .fontWeight(.bold)
                            +
                            Text(" \(content)")
                        }
                        .font(.callout)
                    }.frame(minHeight: 40)
                    
                    Spacer()
                    
                    KFImage(eventImageURL)
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
    let metadata = NotificationMetadata(type: "events_summary", userId: UUID().uuidString,  username: "johndoe", postId: UUID().uuidString, groupName: "SLCFC", eventName: "Sunday PickUp", eventImageURL: "event-images/soccer-0.jpg", timestamp: 1725008123)
    EventNotificationToast(content: "Check out 6 events happening in your area that you might enjoy!", metadata: metadata)
}
