//
//  PostView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct PostView: View {
    
    @State var post: Post
    @Binding var posts: [Post]
    @State private var index = ""
    @State private var isLiked = false
    @State private var showComments = false
    
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session: SessionStore
    
    func deletePost() async {
        let res = await postObserver.deletePost(postId: post.id)
        if res {
            posts.removeAll(where: {$0.id == post.id})
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: "https://storage.googleapis.com/olympsis-1/profile-img/" + post.owner.imageURL)){ image in
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
                }.frame(height: 40)
                    .padding(.leading)
                
                Text(post.owner.username)
                    .padding(.leading, 5)
                    .bold()
                Spacer()
                
                Menu{
                    Button(action:{}){
                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                    }
                    if let user = session.user {
                        if user.uuid == post.owner.uuid {
                            Button(role:.destructive, action:{
                                Task{
                                    await deletePost()
                                }
                            }){
                                Label("Remove Post", systemImage: "delete.left")
                                    
                            }
                        }
                    }
                    
                    
                }label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .padding(.trailing)
                        .foregroundColor(Color(uiColor: .label))
                }
            }.frame(height: 50)
            
            if let images = post.images {
                if !images.isEmpty {
                    TabView(selection: $index){
                        ForEach(images, id: \.self){ image in
                            AsyncImage(url: URL(string: image)){ image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .opacity(0.3)
                                    
                            }
                                .tag(image)
                        }
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT/1.7, alignment: .center)
                }
            }
            
            HStack (alignment: .bottom){
                Text(post.body)
                    .font(.callout)
                Spacer()
                Button(action:{self.isLiked.toggle()}){
                    self.isLiked == true ?
                    Image(systemName: "heart.fill")
                        .imageScale(.large)
                        .foregroundColor(.red)
                    : Image(systemName: "heart")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.leading)
                Button(action:{self.showComments.toggle()}){
                    Image(systemName: "bubble.right")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.trailing)
            }.padding(.leading)
            
        }.task {
            if let images = post.images {
                if !images.isEmpty {
                    self.index = images[0]
                }
            }
        }
        .fullScreenCover(isPresented: $showComments) {
            PostComments(post: post)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: Post(id: "", owner: Owner(uuid: "", username: "unnamed_user", imageURL: "88F8C460-0E29-40D4-9D18-31F6B5600553"), clubId: "", body: "event-body", images: [], likes: [String](), comments: [Comment](), createdAt: 0), posts: .constant([Post]())).environmentObject(SessionStore())
    }
}
