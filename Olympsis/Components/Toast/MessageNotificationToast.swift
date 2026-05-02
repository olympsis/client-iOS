//
//  MessageNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

// NOTE: - Implement later

import SwiftUI

struct MessageNotificationToast: View {
    var metadata: NotificationMetadata
    var content: String {
        return ""
    }
    
    var body: some View {
        Group {
            switch metadata.type {
            case .groupMessage:
                EmptyView()
            default:
                EmptyView()
            }
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .groupMessage, userID: UUID().uuidString,  username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC", eventImageURL: "event-images/soccer-0.jpg")
    MessageNotificationToast(metadata: metadata)
}
