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
    
    @State private var index: Int = 0
    @State private var pinned: Bool = false
    @State private var isLiked: Bool = false
    @State private var showMenu: Bool = false
    @State private var showComments: Bool = false
    @State private var status: LOADING_STATE = .pending
    
    @StateObject private var postObserver = PostObserver()
    @StateObject private var uploadObserver = UploadObserver()
    @EnvironmentObject var session: SessionStore
    
    var userImageURL: String {
        guard let user = post.data?.poster,
                let image = user.imageURL else {
            return "https://api.olympsis.com"
        }
        return GenerateImageURL(image)
    }
    
    var orgImageURL: String {
        guard let org = post.data?.organization,
              let image = org.imageURL else {
            return GenerateImageURL("https://api.olympsis.com")
        }
        return GenerateImageURL(image)
    }
    
    var username: String {
        guard let user = post.data?.poster,
              let username = user.username else {
            return "olympsis-user"
        }
        
        return username
    }
    
    var orgName: String {
        guard let org = post.data?.organization,
              let name = org.name else {
            return "Olympsis Organization"
        }
        return name
    }
    
    var images: [String] {
        guard let imgs = post.images else {
            return [String]()
        }
        return imgs.map { i in
            return GenerateImageURL(i)
        }
    }
    
    var timestamp: String {
        guard let time = post.createdAt else {
            return "0 seconds ago"
        }
        return calculateTimeAgo(from: time)
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
              let selectedGroup = session.selectedGroup,
              let club = selectedGroup.club,
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
    
    func isPinned() -> Bool {
        guard let selectedGroup = session.selectedGroup else {
            return false
        }
        if selectedGroup.type == GROUP_TYPE.Club.rawValue {
            guard let club = selectedGroup.club else {
                return false
            }
            if post.type == "announcement" {
                if let data = club.data,
                   let parent = data.parent {
                    return post.id == parent.pinnedPostId
                }
            }
            return post.id == club.pinnedPostId
        } else {
            guard let org = selectedGroup.organization,
                  let pinnedPostId = org.pinnedPostId else {
                return false
            }
            return post.id == pinnedPostId
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if post.type == "post" {
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
                    } .frame(width: 35, height: 35)
                    VStack(alignment: .leading) {
                        Text(username)
                            .bold()
                    }.padding(.leading, 5)
                } else if post.type == "announcement" {
                    AsyncImage(url: URL(string: orgImageURL)){ phase in
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
                    } .frame(width: 35, height: 35)
                    VStack(alignment: .leading) {
                        Text(orgName)
                            .bold()
                        if let type = post.type {
                            Text(type.capitalized)
                                .font(.caption)
                        }
                            
                    }.padding(.leading, 5)
                }
                
                Spacer()
                if pinned {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(Color("color-prime"))
                        .imageScale(.small)
                        .padding(.top, 5)
                }
                Button(action:{ self.showMenu.toggle() }) {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                    .foregroundColor(Color(uiColor: .label))
                }
            }.frame(height: 35)
                .padding(.horizontal, 5)
            
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
            
            VStack(alignment: .leading) {
                Text(post.body)
                    .font(.callout)
                HStack (alignment: .center){
                    Text("Posted \(timestamp)")
                        .font(.caption2)
                        .foregroundStyle(.gray)
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
                    }
                }.padding(.vertical, 5)
            }.padding(.horizontal, 5)
        }
        .fullScreenCover(isPresented: $showComments) {
            if let club = session.selectedGroup?.club {
                PostComments(club: club, post: $post)
            }
        }
        .sheet(isPresented: $showMenu) {
            PostMenu(post: post, posts: $posts, pinned: $pinned)
                .presentationDetents([.height(250)])
        }
        .task {
            if let user = session.user,
                  let uuid = user.uuid,
                  ((post.likes?.first(where: { $0.uuid == uuid })) != nil) {
                self.isLiked = true
            }
            self.pinned = isPinned()
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: POSTS[1], posts: .constant(POSTS)).environmentObject(SessionStore())
    }
}
