//
//  CommentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct CommentView: View {
    @State var comment: Comment
    var body: some View {
        HStack {
            HStack(alignment: .top){
                AsyncImage(url: URL(string: "https://storage.googleapis.com/olympsis-1/profile-img/" + comment.imageURL)){ image in
                    image.resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 40, height: 40)
                        
                } placeholder: {
                    Circle()
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: 40)
                }.frame(height: 50)
                    .padding(.leading)
                VStack (alignment: .leading){
                    Group {
                        Text(comment.username)
                            .fontWeight(.bold)
                        + Text(" \(comment.text)")
                    }.padding(.leading, 4)
                    Text(" \(Date(timeIntervalSince1970: TimeInterval(comment.createdAt)).formatted(.dateTime.day().month().year().hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }.padding(.trailing)
            }
            Spacer()
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: Comment(id: "", username: "johndoe", uuid: "000", text: "Lets go!!!", imageURL: "88F8C460-0E29-40D4-9D18-31F6B5600553", createdAt: 1669663779))
    }
}
