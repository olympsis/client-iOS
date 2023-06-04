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
        guard let user = comment.data,
              let image = user.imageURL else {
            return ""
        }
        return GenerateImageURL(image)
    }
    
    var username: String {
        guard let data = comment.data,
              let username = data.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var timeStamp: String {
        guard let time = comment.createdAt else {
            return "0 minutes ago"
        }
        return calculateTimeAgo(from: time)
    }
    
    var body: some View {
        HStack {
            HStack(alignment: .top){
                AsyncImage(url: URL(string: imageURL)){ phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .clipShape(Circle())
                            .scaledToFill()
                            .clipped()
                    } else if phase.error != nil {
                        Color.gray // Indicates an error.
                            .clipShape(Circle())
                            .opacity(0.3)
                    } else {
                        ZStack {
                            Color.gray // Acts as a placeholder.
                                .clipShape(Circle())
                            .opacity(0.3)
                            ProgressView()
                        }
                    }
                }.frame(width: 35, height: 35)
                    .padding(.leading, 5)
                VStack (alignment: .leading){
                    Group {
                        Text(username)
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("\(comment.text)")
                            .font(.custom("helvetica", size: 15))
                    }
                    Text(timeStamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }.padding(.trailing)
            }.foregroundColor(.primary)
                .padding(.bottom)
            Spacer()
        }.padding(.leading, 5)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: Comment(id: "", uuid: "000", text: "is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", data: nil, createdAt: 1639364779)).environmentObject(SessionStore())
    }
}
