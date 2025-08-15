//
//  ReportNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/13/25.
//

import SwiftUI
import Kingfisher

struct ReportNotificationToast: View {
    var metadata: NotificationMetadata
    
    private var content: String {
        switch metadata.type {
        case .postReport:
            return "A new post report was filed."
        case .memberReport:
            return "A new member report was filed."
        default:
            return "A new report was made about a comment."
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
    
    let size: CGFloat = 40
    
    var body: some View {
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
        }.padding(.horizontal)
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .postReport, userID: UUID().uuidString,  username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC", eventImageURL: "event-images/soccer-0.jpg")
    
    RoundedRectangle(cornerRadius: 10)
        .frame(height: 60)
        .padding(.horizontal, 10)
        .foregroundStyle(Color.Background.secondary)
        .overlay {
            ReportNotificationToast(metadata: metadata)
        }
}
