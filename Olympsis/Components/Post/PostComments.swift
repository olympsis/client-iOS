//
//  PostComments.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct PostComments: View {
    
    @State var club: Club
    
    @State private var text = ""
    @FocusState private var keyboardFocused: Bool
    @State private var status: LOADING_STATE = .pending
    
    @EnvironmentObject private var post: Post
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss
    
    func canDelete(_ comment: Comment) -> Bool {
        guard let user = session.user,
              let userID = user.userID else {
            return false
        }
        return (userID == post.poster?.userID) || (userID == comment.user?.userID)
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
              let userID = user.userID,
              let username = user.username,
              let imageURL = user.imageURL,
              text.count >= 2 else {
            handleFailure()
            return
        }
        let dao = CommentDao(id: nil, text: text, userID: userID, createdAt: nil)
        let resp = await session.postObserver.addComment(id: post.id, comment: dao)
        guard resp != nil else {
            handleFailure()
            return
        }
        status = .success
        
        let comment = Comment(id: UUID().uuidString, text: text, user: UserSnippet(userID: userID, username: username, imageURL: imageURL), createdAt: Date())
        
        withAnimation {
            text = ""
            post.comments.append(comment)
        }
    }
    
    func deleteComment(_ comment: Comment) {
        Task {
            let res = await session.postObserver.deleteComment(id: post.id, cid: comment.id)
            if res {
                post.comments.removeAll(where: { $0.id == comment.id })
            }
        }
    }
    
    func isCommentOwner(_ comment: Comment) -> Bool {
        guard let user = session.user,
              let userID = user.userID else {
            return false
        }
        return comment.user?.userID == userID
    }
    
    var isPostOwner: Bool {
        guard let user = session.user,
              let userID = user.userID else {
            return false
        }
        return post.poster?.userID == userID
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    if post.comments.count != 0 {
                        ForEach(post.comments.sorted{ $0.createdAt > $1.createdAt }, id: \.id){ comment in
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
                }
                .padding(.bottom, 50)
                .listStyle(.plain)
                .refreshable {
                    guard let resp = await session.postObserver.getPost(id: post.id) else {
                        return
                    }
                    post.comments = resp.comments
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
                                    .foregroundStyle(Color(Color.Background.secondary))
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

#Preview("Post Comments") {
    PostComments(club: CLUBS[0])
        .environmentObject(POSTS[0])
        .environment(SessionStore())
}
