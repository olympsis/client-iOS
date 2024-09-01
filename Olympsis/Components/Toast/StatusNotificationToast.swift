//
//  StatusNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/24.
//

import SwiftUI

struct StatusNotificationToast: View {
    
    var type: STATUS_TOAST_TYPES
    var content: String
    var metadata: NotificationMetadata
    
    init(content: String, metadata: NotificationMetadata) {
        self.type = STATUS_TOAST_TYPES(rawValue: metadata.type) ?? .warning
        self.content = content
        self.metadata = metadata
    }
    
    var body: some View {
        Group {
            switch type {
            case .warning:
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    
                    Text(content)
                }
            case .success:
                HStack {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    
                    Text(content)
                }
            case .error:
                HStack {
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                    
                    Text(content)
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    StatusNotificationToast(content: "Post created successfully!", metadata: NotificationMetadata(type: "error"))
}
