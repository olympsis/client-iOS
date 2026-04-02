//
//  EventNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI
import Kingfisher

struct EventNotificationToast: View {
    
    var metadata: NotificationMetadata
    
    var content: String {
        switch metadata.type {
        case .newEvent:
            return "created a new event"
        case .eventReminder:
            guard let c = metadata.content else {
                return "event is starting soon..."
            }
            return c
        default:
            return "RSVP'ed to the event"
        }
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
            return "olympsis-event"
        }
        return name
    }
    
    var eventImageURL: URL? {
        guard let postImg = metadata.eventImageURL else {
            return nil
        }
        return generateImageURL(postImg)
    }
    
    let size: CGFloat = 40
    
    @State private var postImageFailed = false
    @State private var profileImageFailed = false
    
    var body: some View {
        Group {
            switch metadata.type {
            case .newEvent:
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
            case .eventReminder:
                HStack(alignment: .center, spacing: 10) {
                    
                    KFImage(eventImageURL)
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
                    
                    Group {
                        Text("\(eventName) ")
                            .fontWeight(.bold)
                        +
                        Text(content)
                    }.frame(minHeight: 40)
                        
                    
                    Spacer()
                }
            default:
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
                        .frame(width: size, height: size+10)
                    
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
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .newEvent, userID: UUID().uuidString,  username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC", eventName: "Sunday PickUp", eventImageURL: "event-images/soccer-0.jpg")
    
//    let statusData = NotificationMetadata(type: .eventReminder, userID: UUID().uuidString,  username: "janedoe", postID: UUID().uuidString, groupName: "SLCFC", eventName: "Sunday PickUp", eventImageURL: "event-images/soccer-0.jpg")
    
//    let participantData = NotificationMetadata(type: .eventParticipantUpdate, userID: UUID().uuidString,  username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC", eventName: "Sunday PickUp", eventImageURL: "event-images/soccer-0.jpg")
    
    RoundedRectangle(cornerRadius: 10)
        .frame(height: 60)
        .padding(.horizontal, 10)
        .foregroundStyle(Color.Background.secondary)
        .overlay {
            EventNotificationToast(metadata: metadata)
        }
}
