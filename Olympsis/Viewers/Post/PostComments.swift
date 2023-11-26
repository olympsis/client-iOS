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
    @State private var comments: [Comment] = [Comment]()
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
        comments.append(data)
    }
    
    func deleteComment(_ comment: Comment) {
        Task {
            guard let id = post.id,
            let commentID = comment.id else {
                return
            }
            let res = await session.postObserver.deleteComment(id: id, cid: commentID)
            if res {
                comments.removeAll(where: { $0.id == commentID })
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
                    if comments.count != 0 {
                        ForEach(comments.sorted{$0.createdAt! > $1.createdAt!}, id: \.id){ comment in
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
                                HStack {
                                    CommentView(comment: comment)
                                    Spacer()
                                }
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
                        guard let c = resp.comments else {
                            return
                        }
                        comments = c
                    }
                    .task {
                        guard let c = post.comments else {
                            return
                        }
                        comments = c
                    }

                VStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                            .foregroundColor(Color("color-secnd"))
                            .opacity(0.2)
                        TextField("Add a Comment", text: $text)
                            .padding(.leading)
                            .submitLabel(.send)
                            .onSubmit {
                                Task {
                                    await addComment()
                                }
                            }
                    }.padding(.bottom)
                    .padding(.horizontal)
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
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
