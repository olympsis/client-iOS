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
    @State var data: PostData?
    @State private var index = ""
    @State private var isLiked = false
    @State private var showComments = false
    @State private var status: LOADING_STATE = .pending
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session: SessionStore
    
    func deletePost() async {
        guard let id = post.id else {
            return
        }
        let res = await postObserver.deletePost(postID: id)
        if res {
            guard let id = club.id else {
                return
            }
            session.posts[id]?.removeAll(where: {$0.id == id})
        }
    }
    
    var userImageURL: String {
        guard let user = data?.user,
                let image = user.imageURL else {
            return ""
        }
        return GenerateImageURL(image)
    }
    
    var username: String {
        guard let user = data?.user,
              let username = user.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var images: [String] {
        guard let imgs = post.images else {
            return [String]()
        }
        return imgs.map { i in
            return GenerateImageURL(i)
        }
    }
    
    var isPoster: Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return uuid == post.poster
    }
    
    var isAdmin: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let members = club.members,
              let member = members.first(where: { $0.uuid == uuid }) else {
            return false
        }
        return member.role != "member"
    }
    
    func like() async {
        guard let id = post.id,
            let user = session.user,
            let uuid = user.uuid else {
            return
        }
        let like = Like(id: nil, uuid: uuid, createdAt: nil)
        let resp = await session.postObserver.addLike(id: id, like: like)
        guard let lk = resp else {
            return
        }
        guard var likes = post.likes else {
            post.likes = [lk]
            return
        }
        self.isLiked = true
        likes.append(lk)
    }
    
    func removeLike() async {
        guard let id = post.id, let likes = post.likes,
                let user = session.user, let uuid = user.uuid,
              let like = likes.first(where: {$0.uuid == uuid }) else {
            return
        }
        let resp = await session.postObserver.deleteLike(id: id, likeID: like.id ?? "")
        if resp {
            self.isLiked = false
            post.likes?.removeAll(where: {$0.id == like.id})
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: userImageURL)){ phase in
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
                Text(username)
                    .padding(.leading, 5)
                    .bold()
                
                Spacer()
                
                Menu{
                    Button(action:{}){
                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                    }
                    if isPoster || isAdmin {
                        Button(role:.destructive, action:{
                            Task{
                                await deletePost()
                            }
                        }){
                            Label("Remove Post", systemImage: "delete.left")
                        }
                    }
                    
                    
                }label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .padding(.trailing)
                        .foregroundColor(Color(uiColor: .label))
                }
            }.frame(height: 35)
            
            if images.count > 0 {
                TabView(selection: $index){
                    ForEach(images, id: \.self){ image in
                        AsyncImage(url: URL(string: image)){ image in
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
            
            HStack (alignment: .bottom){
                Text(post.body)
                    .font(.callout)
                Spacer()
                Button(action:{
                    Task {
                        self.isLiked == true ? await removeLike() : await like()
                    }
                }){
                    self.isLiked == true ?
                    Image(systemName: "heart.fill")
                        .imageScale(.large)
                        .foregroundColor(.red)
                    : Image(systemName: "heart")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.leading)
                Button(action:{ self.showComments.toggle() }){
                    Image(systemName: "bubble.right")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.trailing)
            }.padding(.leading)
            
        }
        .fullScreenCover(isPresented: $showComments) {
            PostComments(club: club, post: $post)
        }
        .task {
            guard let user = session.user,
                    let likes = post.likes else {
                return
            }
            self.isLiked = likes.first(where: { $0.uuid == user.uuid }) != nil
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(club: CLUBS[0], post: POSTS[0], data: POSTS[0].data).environmentObject(SessionStore())
    }
}
