//
//  ToastView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/25/24.
//

import SwiftUI

struct ToastView: View {
    
    var type: TOAST_TYPE
    var content: String
    var metadata: NotificationMetadata
    
    init(_ type: TOAST_TYPE, content: String, metadata: NotificationMetadata) {
        self.type = type
        self.content = content
        self.metadata = metadata
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 60)
            .padding(.horizontal, 10)
            .foregroundStyle(Color.Background.secondary)
            .overlay {
//                switch type {
//                case .post:
//                    PostNotificationToast(content: content, metadata: metadata)
//                case .event:
//                    EventNotificationToast(content: content, metadata: metadata)
//                case .group:
//                    GroupNotificationToast(content: content, metadata: metadata)
//                case .friend:
//                    EmptyView() // NOTE: - Implement when we have the friend service
//                case .status:
//                    StatusNotificationToast(content: content, metadata: metadata)
//                case .message:
//                    MessageNotificationToast(content: content, metadata: metadata)
//                }
            }
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .eventParticipantUpdate, userID: UUID().uuidString, username: "johndoe", userImageURL:"profile-images/2CE19A66-695E-4532-98FC-E759415A9721.jpeg", postID: UUID().uuidString, postImageURL: "feed-images/44BB4716-22E6-474A-AA2F-3EC69048C4BF.jpeg", groupName: "SLCFC")
    ToastView(.event, content: "rsvped to your event", metadata: metadata)
}
