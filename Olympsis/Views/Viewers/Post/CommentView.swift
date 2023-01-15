//
//  CommentView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct CommentView: View {
    @State var data: UserPeek?
    @State var comment: Comment
    var body: some View {
        HStack {
            HStack(alignment: .top){
                if let d = data {
                    if let img = d.imageURL {
                        AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + img)){ phase in
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
                    } else {
                        Circle()
                            .foregroundColor(.gray)
                            .opacity(0.3)
                            .frame(width: 35)
                            .padding(.leading, 5)
                    }
                    VStack (alignment: .leading){
                        Group {
                            Text(d.username)
                                .fontWeight(.bold)
                            + Text(" \(comment.text)")
                        }.padding(.leading, 4)
                        Text(" \(Date(timeIntervalSince1970: TimeInterval(comment.createdAt)).formatted(.dateTime.day().month().year().hour().minute()))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }.padding(.trailing)
                } else {
                    HStack {
                        Circle()
                            .foregroundColor(.gray)
                            .opacity(0.3)
                            .frame(width: 35)
                        .padding(.leading, 5)
                        
                        VStack (alignment: .leading){
                            Group {
                                Text("olympsis-user")
                                    .fontWeight(.bold)
                                + Text(" \(comment.text)")
                            }.padding(.leading, 4)
                            Text(" \(Date(timeIntervalSince1970: TimeInterval(comment.createdAt)).formatted(.dateTime.day().month().year().hour().minute()))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }.padding(.trailing)
                    }
                }
            }
            Spacer()
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "profile-images/62D674D2-59D2-4095-952B-4CE6F55F681F", bio: "", sports: ["soccer"])
        CommentView(data: peek, comment: Comment(id: "", uuid: "000", text: "Lets go!!!", createdAt: 1669663779))
    }
}
