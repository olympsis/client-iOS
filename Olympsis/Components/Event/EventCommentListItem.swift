//
//  EventComment.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct EventCommentListItem: View {
    
    var comment: EventComment
    
    var posterName: String {
        guard let user = comment.user,
              let firstName = user.firstName,
              let lastName = user.lastName else {
            return "Olympsis User"
        }
        
        return "\(firstName) \(lastName)"
    }
    
    var posterUsername: String {
        guard let user = comment.user,
              let username = user.username else {
            return "@olympsis-user"
        }
        
        return "@\(username)"
    }
    
    var posterImageURL: URL? {
        guard let user = comment.user,
              let imageURLString = user.imageURL else {
            return nil
        }
        
        return generateImageURL(imageURLString)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                UserBadgeView(size: .small, imageURL: posterImageURL)
                HStack(alignment: .center) {
                    Text(posterName)
                        .font(.callout)
                    
                    Text(calculateTimeAgo(from: comment.createdAt))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
            }
            
            HStack {
                Text(comment.text)
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    EventCommentListItem(comment: EVENT_COMMENTS[0])
}
