//
//  MessageNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

// NOTE: - Implement later

import SwiftUI

struct MessageNotificationToast: View {
    
    var type: MESSAGE_TOAST_TYPES
    var content: String
    var metadata: NotificationMetadata
    
    init(content: String, metadata: NotificationMetadata) {
        self.type = MESSAGE_TOAST_TYPES(rawValue: metadata.type) ?? .newMessage
        self.content = content
        self.metadata = metadata
    }
    
    var body: some View {
        Group {
            switch type {
            case .messageRequest:
                EmptyView()
            case .newMessage:
                EmptyView()
            case .newGroupMessage:
                EmptyView()
            case .addedToGroup:
                EmptyView()
            case .removedFromGroup:
                EmptyView()
            }
        }.padding(.horizontal)
    }
}

#Preview {
    MessageNotificationToast(content: "", metadata: NotificationMetadata(type: "new_message"))
}
