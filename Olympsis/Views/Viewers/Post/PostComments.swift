//
//  PostComments.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct PostComments: View {
    @State var club: Club
    @State var post: Post
    @State private var comments = [Comment]()
    @State private var text = ""
    
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func GetData(uuid: String) -> UserPeek? {
        let usr = club.members.first(where: {$0.uuid == uuid})
            if let u = usr {
                return u.data
            }
        return nil
    }
    
    func addComment() async {
        if let user = session.user {
            let dao = CommentDao(_uuid: user.uuid, _text: text)
            let res = await postObserver.addComment(id: post.id, dao: dao)
            if res {
                let _comments = await postObserver.getComments(id: post.id)
                comments = _comments
                text = ""
            }
        }
    }
    
    func deleteComment(at offsets: IndexSet) {
        if let first = offsets.first {
            let c = comments[first]
            Task {
                let res = await postObserver.deleteComment(id: post.id, cid: c.id)
                if res {
                    comments.remove(atOffsets: offsets)
                }
            }
        }
    }
    var body: some View {
        NavigationView {
            VStack {
                ZStack(){
                    if !comments.isEmpty {
                        List {
                            ForEach(comments.sorted{$0.createdAt > $1.createdAt}, id: \.createdAt){ comment in
                                CommentView(data: GetData(uuid: comment.uuid), comment: comment)
                            }.onDelete(perform: deleteComment)
                        }.listStyle(.plain)
                    } else {
                        Text("No Comments")
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
                }
                
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                let _comments = await postObserver.getComments(id: post.id)
                comments = _comments
            }
        }
    }
}

struct PostComments_Previews: PreviewProvider {
    static var previews: some View {
        let post = Post(id: "", owner: "", clubId: "", body: "post-body", images: [String](), likes: [String](), comments: [Comment](), createdAt: 0)
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        PostComments(club: club, post: post)
    }
}
