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
    @FocusState private var keyboardFocused: Bool
    @State private var status: LOADING_STATE = .pending
    @State private var comments: [Comment] = [Comment]()
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    func canDelete(_ comment: Comment) -> Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return (uuid == post.poster) || (uuid == comment.uuid)
    }
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func addComment() async {
        status = .loading
        keyboardFocused = false
        guard let user = session.user,
              let id = post.id,
              let uuid = user.uuid,
              let username = user.username,
              let firstName = user.firstName,
              let lastName = user.lastName,
              let imageURL = user.imageURL,
              text.count >= 2 else {
            handleFailure()
            return
        }
        let comment = Comment(id: nil, uuid: uuid, text: text, data: nil, createdAt: nil)
        let resp = await session.postObserver.addComment(id: id, comment: comment)
        guard var data = resp else {
            handleFailure()
            return
        }
        status = .success
        data.data = UserData(username: username, firstName: firstName, lastName: lastName, imageURL: imageURL)
        withAnimation {
            comments.append(data)
            text = ""
        }
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
                        VStack {
                            HStack {
                                Spacer()
                            }
                            Spacer()
                            Text("No Comments")
                            Spacer()
                        }
                    }
                }.padding(.bottom, 50)
                .listStyle(.plain)
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
                    .overlay {
                        VStack {
                            Spacer()
                            HStack(alignment: .center) {
                                ZStack {
                                    TextField("Add a Comment", text: $text)
                                        .padding(.leading)
                                        .focused($keyboardFocused)
                                }.frame(height: 40)
                                if (text.count > 0) {
                                    Button(action:{ Task { await addComment() } }) {
                                        LoadingButton(text: "", image: Image(systemName: "paperplane.fill"), width: 40, status: $status)
                                            .padding(.trailing, 5)
                                    }
                                }
                            }.ignoresSafeArea(.keyboard)
                                .frame(height: 50)
                                .background {
                                    Rectangle()
                                        .frame(height: 50)
                                        .foregroundStyle(Color("background"))
                                }
                        }
                    }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action:{ dismiss() }) {
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
