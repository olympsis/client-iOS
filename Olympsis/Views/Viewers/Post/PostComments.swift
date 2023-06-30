//
//  PostComments.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct PostComments: View {
    @State var club: Club
    @Binding var post: Post
    @State private var text = ""
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func canDelete(_ comment: Comment) -> Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return (uuid == post.poster) || (uuid == comment.uuid)
    }
    
    func addComment() async {
        guard let user = session.user,
              let id = post.id,
              let uuid = user.uuid,
              let username = user.username,
              let firstName = user.firstName,
              let lastName = user.lastName,
              let imageURL = user.imageURL,
              text.count >= 2 else {
            return
        }
        let comment = Comment(id: nil, uuid: uuid, text: text, data: nil, createdAt: nil)
        let resp = await session.postObserver.addComment(id: id, comment: comment)
        guard var data = resp else {
            return
        }
        text = ""
        data.data = UserData(username: username, firstName: firstName, lastName: lastName, imageURL: imageURL)
        guard post.comments != nil else {
            post.comments = [data]
            return
        }
        post.comments?.append(data)
    }
    
    func deleteComment(_ comment: Comment) {
        Task {
            guard let id = post.id,
            let commentID = comment.id else {
                return
            }
            let res = await session.postObserver.deleteComment(id: id, cid: commentID)
            if res {
                post.comments?.removeAll(where: { $0.id == commentID })
            }
        }
    }
    
    func isCommentOwner(_ comment: Comment) -> Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return comment.uuid == uuid
    }
    
    var isPostOwner: Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return post.poster == uuid
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    if post.comments != nil {
                        ForEach(post.comments?.sorted{$0.createdAt! > $1.createdAt!} ?? [Comment](), id: \.id){ comment in
                            Menu {
                                Group {
                                    Button(action:{}){
                                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                                    }
                                    if isPostOwner || isCommentOwner(comment) {
                                        Button(role: .destructive, action: { Task { deleteComment(comment) } }, label: {
                                            Label("Delete Comment", systemImage: "exclamationmark.shield")
                                        })
                                    }
                                }
                            } label: {
                                CommentView(comment: comment)
                            } primaryAction: {
                                
                            }

                        }
                    } else {
                        Text("No Comments")
                    }
                }.listStyle(.plain)
                    .refreshable {
                        guard let id = post.id,
                                let resp = await session.postObserver.getPost(id: id) else {
                            return
                        }
                        post = resp
                    }

                VStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.2)
                        TextField("Add a Comment", text: $text)
                            .padding(.leading)
                            .submitLabel(.send)
                            .onSubmit {
                                Task {
                                    await addComment()
                                }
                            }
                    }.frame(width: SCREEN_WIDTH-30)
                        .padding(.bottom)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PostComments_Previews: PreviewProvider {
    static var previews: some View {
        PostComments(club: CLUBS[0], post: .constant(POSTS[0])).environmentObject(SessionStore())
    }
}
