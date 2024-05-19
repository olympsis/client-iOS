//
//  PostView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI
import Kingfisher

struct PostView: View {
    
    @State var post: Post
    @Binding var posts: [Post]
    
    @State private var pinned: Bool = false
    @State private var showMenu: Bool = false
    @State private var showComments: Bool = false

    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack {
            PostHeader(post: $post, pinned: $pinned, showMenu: $showMenu)
            
            PostBody(post: $post)
            
            PostFooter(post: $post, showComments: $showComments)
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
    }
}


struct PostHeader: View {
    
    @Binding var post: Post
    @Binding var pinned: Bool
    @Binding var showMenu: Bool
    @EnvironmentObject private var session: SessionStore
    
    var isOrg: Bool {
        guard let selectedGroup = session.selectedGroup,
              selectedGroup.organization != nil else {
            return false
        }
        return true
    }
    
    var userImageURL: String {
        guard let user = post.poster,
                let image = user.imageURL else {
            return "https://api.olympsis.com"
        }
        return GenerateImageURL(image)
    }
    
    var orgImageURL: String {
        guard let club = session.selectedGroup?.club,
              let org = club.parent,
              let image = org.imageURL else {
            return GenerateImageURL("https://api.olympsis.com")
        }
        return GenerateImageURL(image)
    }
    
    var username: String {
        guard let user = post.poster,
              let username = user.username,
              username != "" else {
            return "olympsis-user"
        }
        
        return username
    }
    
    var orgName: String {
        guard let club = session.selectedGroup?.club,
              let org = club.parent,
              let name = org.name,
              name != "" else {
            return "Olympsis Organization"
        }
        return name
    }
    
    func isPinned() -> Bool {
        guard let selectedGroup = session.selectedGroup else {
            return false
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                return false
            }
            if post.type == "announcement" {
                if let parent = club.parent {
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
        HStack {
            switch post.type {
            case "post":
                AsyncImage(url: URL(string: userImageURL)){ phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .clipShape(Circle())
                            .scaledToFill()
                            .clipped()
                    } else if phase.error != nil {
                        Color("background") // Indicates an error.
                            .clipShape(Circle())
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color("foreground"))
                            }
                    } else {
                        ZStack {
                            Color("background") // Acts as a placeholder.
                                .clipShape(Circle())
                            ProgressView()
                        }
                    }
                } .frame(width: 35, height: 35)
                VStack(alignment: .leading) {
                    Text(username)
                        .bold()
                }.padding(.leading, 5)
            case "announcement":
                if (!isOrg) {
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
                                .overlay {
                                    Image(systemName: "building")
                                        .foregroundStyle(.white)
                                }
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
                } else {
                    AsyncImage(url: URL(string: userImageURL)){ phase in
                        if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .clipShape(Circle())
                                .scaledToFill()
                                .clipped()
                        } else if phase.error != nil {
                            Color("background") // Indicates an error.
                                .clipShape(Circle())
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color("foreground"))
                                }
                        } else {
                            ZStack {
                                Color("background") // Acts as a placeholder.
                                    .clipShape(Circle())
                                ProgressView()
                            }
                        }
                    }
                    .frame(width: 35, height: 35)
                    VStack(alignment: .leading) {
                        Text(username)
                            .bold()
                    }
                    .padding(.leading, 5)
                }
            case "advertisement":
                EmptyView()
            case .none:
                EmptyView()
            case .some(_):
                EmptyView()
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
                    .imageScale(.medium)
                    .foregroundColor(Color(uiColor: .label))
            }
        }
        .frame(height: 35)
        .padding(.horizontal, 5)
        .task {
            self.pinned = isPinned()
        }
    }
}

struct PostBody: View {
    
    @Binding var post: Post
    @State private var index: Int = 0
    
    // post images links wrapped up in a url
    var imagesURL: [URL] {
        var urls = [URL]()
        guard let imgs = post.images else {
            return [URL]()
        }
        
        imgs.forEach { i in
            if let url = generateImageURL(i) {
                urls.append(url)
            }
        }
        
        return urls
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if imagesURL.count > 0 {
                TabView(selection: $index){
                    ForEach(imagesURL.indices, id: \.self){ i in
                        KFImage(imagesURL[i])
                            .placeholder({
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.gray)
                                        .opacity(0.3)
                                    ProgressView()
                                }
                            })
                            .resizable(resizingMode: .stretch)
                            .scaledToFill()
                            .clipped()
                            .tag(i)
                    }
                }
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: SCREEN_WIDTH)
            }
            
            HStack {
                Text(post.body)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 5)
                Spacer()
            }
        }
    }
}

struct PostFooter: View {
    
    @Binding var post: Post
    @Binding var showComments: Bool
    @State private var isLiked: Bool = false
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var session: SessionStore
    
    var likeCount: Int {
        guard let likes = post.likes else {
            return 0
        }
        return likes.count
    }
    
    var timestamp: String {
        guard let time = post.createdAt else {
            return "0 seconds ago"
        }
        return calculateTimeAgo(from: time)
    }
    
    private var hasExternalLink: Bool {
        guard let ext = self.post.externalLink,
              ext != "" else {
            return false
        }
        return true
    }
    
    func like() async {
        guard let id = post.id,
            let user = session.user,
            let uuid = user.uuid else {
            return
        }
        let dao = LikeDao(uuid: uuid)
        guard let id = await session.postObserver.addLike(id: id, like: dao) else {
            return
        }
        let snippet = UserSnippet(uuid: uuid, username: user.username ?? "", imageURL: user.imageURL ?? "")
        let like = Like(id: id, uuid: uuid, user: snippet, createdAt: Int(Date.now.timeIntervalSince1970))
        isLiked = true
        guard post.likes != nil else {
            post.likes = [like]
            return
        }
        post.likes?.append(like)
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
            post.likes?.removeAll(where: {$0.uuid == like.uuid}) // i would use id instead but this is also more sure
            isLiked = false
        }
    }
    
    var body: some View {
        VStack {
            HStack (alignment: .center){
                Text("Posted \(timestamp)")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Spacer()
                if hasExternalLink {
                    HStack {
                        Button(action: {
                            guard let extLink = post.externalLink,
                                  let url = URL(string: extLink), UIApplication.shared.canOpenURL(url) else {
                                return
                            }
                            openURL(url)
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.caption)
                                Text("Learn More")
                                    .font(.caption)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                        }.padding(.trailing, 5)
                    }
                }
                Spacer()
                Button(action:{
                    Task {
                        self.isLiked == true ? await removeLike() : await like()
                    }
                }){
                    self.isLiked == true ?
                    Image(systemName: "heart.fill")
                        .imageScale(.medium)
                        .foregroundColor(.red)
                    : Image(systemName: "heart")
                        .imageScale(.medium)
                        .foregroundColor(.primary)
                }.padding(.leading)
                if likeCount > 0 {
                    Text("\(likeCount)")
                        .font(.callout)
                }
                Button(action:{ self.showComments.toggle() }){
                    Image(systemName: "bubble.right")
                        .imageScale(.medium)
                        .foregroundColor(.primary)
                }
            }
            .padding(.all, 5)
            .task {
                if let user = session.user,
                      let uuid = user.uuid,
                      ((post.likes?.first(where: { $0.uuid == uuid })) != nil) {
                    self.isLiked = true
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color("background"))
        }
    }
}

#Preview("Header") {
    PostHeader(post: .constant(POSTS[0]), pinned: .constant(false), showMenu: .constant(false))
        .environmentObject(SessionStore())
}

#Preview("Body") {
    PostBody(post: .constant(POSTS[1]))
}

#Preview("Footer") {
    PostFooter(post: .constant(POSTS[0]), showComments: .constant(false))
        .environmentObject(SessionStore())
}

#Preview {
    PostView(post: POSTS[0], posts: .constant(POSTS))
        .environmentObject(SessionStore())
}
