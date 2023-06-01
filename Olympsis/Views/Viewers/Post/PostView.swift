//
//  PostView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct PostView: View {
    @State var club: Club
    @State var post: Post
    @State var data: UserData?
    @Binding var posts: [Post]
    @State private var index = ""
    @State private var isLiked = false
    @State private var showComments = false
    @State private var status: LOADING_STATE = .pending
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
                        } .frame(width: 35)
                            .padding(.leading, 5)
                    } else {
                        Circle()
                            .foregroundColor(.gray)
                            .opacity(0.3)
                            .frame(width: 35)
                            .padding(.leading, 5)
                    }
                    Text(d.username!)
                        .padding(.leading, 5)
                        .bold()
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: 35)
                        .padding(.leading, 5)
                    Text("Unknown User")
                        .padding(.leading, 5)
                        .bold()
                }
                Spacer()
                
                Menu{
                    Button(action:{}){
                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                    }
                    if let user = session.user {
                        if user.uuid == post.owner {
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
            }.frame(height: 35)
            
            if let images = post.images {
                if !images.isEmpty {
                    TabView(selection: $index){
                        ForEach(images, id: \.self){ image in
                            AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + image)){ image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                            } placeholder: {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.gray)
                                    .opacity(0.3)
                                    ProgressView()
                                }
                                    
                            }
                                .tag(image)
                        }
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(width: SCREEN_WIDTH, height: 500, alignment: .center)
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
            PostComments(club: club, post: post)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(club: CLUBS[0], post: POSTS[0], data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: nil, clubs: nil, sports: nil, deviceToken: nil), posts: .constant(POSTS)).environmentObject(SessionStore())
    }
}
