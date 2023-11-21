//
//  PostView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI

struct PostView: View {
    @Binding var club: Club
    @State var post: Post
    @Binding var index: Int
    @Binding var showMenu: Bool
    @State private var isLiked = false
    @State private var showComments = false
    @State private var status: LOADING_STATE = .pending
    
    @StateObject private var postObserver = PostObserver()
    @StateObject private var uploadObserver = UploadObserver()
    
    @EnvironmentObject var session: SessionStore
    
    var userImageURL: String {
        guard let user = post.data?.user,
                let image = user.imageURL else {
            return ""
        }
        return GenerateImageURL(image)
    }
    
    var username: String {
        guard let user = post.data?.user,
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
        
        isLiked = true
        guard post.likes != nil else {
            post.likes = [lk]
            return
        }
        post.likes?.append(lk)
    }
    
    func removeLike() async {
        guard let id = post.id, let likes = post.likes,
                let user = session.user, let uuid = user.uuid,
              let like = likes.first(where: {$0.uuid == uuid }),
              let lID = like.id else {
            return
        }
        let resp = await session.postObserver.deleteLike(id: id, likeID: lID)
        if resp {
            post.likes?.removeAll(where: {$0.id == like.id})
            isLiked = false
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
                VStack(alignment: .leading) {
                    Text(username)
                        
                    .bold()
                    if (post.type != "regular") {
                        Text(post.type)
                            .font(.caption)
                    }
                }.padding(.leading, 5)
                
                Spacer()
                
                Button(action:{ self.showMenu.toggle() }) {
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
                  let uuid = user.uuid,
                  ((post.likes?.first(where: { $0.uuid == uuid })) != nil) else {
                self.isLiked = false
                return
            }
            self.isLiked = true
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(club: .constant(CLUBS[0]), post: POSTS[1],index: .constant(0), showMenu: .constant(false)).environmentObject(SessionStore())
    }
}
