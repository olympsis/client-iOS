//
//  CommentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct CommentView: View {
    
    @State var comment: Comment
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode

    var imageURL: String {
        guard let user = comment.user,
              let image = user.imageURL else {
            return ""
        }
        return GenerateImageURL(image)
    }
    
    var username: String {
        guard let user = comment.user,
              let username = user.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var timeStamp: String {
        guard let time = comment.createdAt else {
            return "0 seconds ago"
        }
        return calculateTimeAgo(from: time)
    }
    
    var body: some View {
        HStack(alignment: .top){
            AsyncImage(url: URL(string: imageURL)){ phase in
                if let image = phase.image {
                    image // Displays the loaded image.
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFill()
                        .clipped()
                } else if phase.error != nil || imageURL == "" {
                    Color.gray // Indicates an error.
                        .clipShape(Circle())
                        .opacity(0.3)
                        .overlay {
                            Image(systemName: "person")
                                .foregroundStyle(.primary)
                        }
                } else {
                    ZStack {
                        Color.gray // Acts as a placeholder.
                            .clipShape(Circle())
                        .opacity(0.3)
                        ProgressView()
                    }
                }
            }.frame(width: 35, height: 35)
            VStack(alignment: .leading){
                Text(username)
                    .font(.caption)
                    .bold()
                Text("\(comment.text)")
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                Text(timeStamp)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.vertical, 1)
            }
        }.foregroundColor(.primary)
            .padding(.bottom)
            .padding(.horizontal, 5)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: COMMENTS[0]).environmentObject(SessionStore())
    }
}
