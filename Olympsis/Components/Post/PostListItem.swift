//
//  PostView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI
import Kingfisher

struct PostListItem: View {
    
    @State private var pinned: Bool
    @State private var showMenu: Bool
    @State private var showComments: Bool
    @State private var showAlert: Bool = false
    
    @StateObject private var post: Post
    @Environment(SessionStore.self) private var session
    @EnvironmentObject private var feedModel: FeedViewModel
    
    init(post: Post, pinned: Bool = false, showMenu: Bool = false, showComments: Bool = false) {
        self._post = StateObject(wrappedValue: post)
        self.pinned = pinned
        self.showMenu = showMenu
        self.showComments = showComments
    }
    
    var body: some View {
        VStack {
            PostHeader(pinned: $pinned, showMenu: $showMenu)
                .environmentObject(post)
            
            PostBody()
                .environmentObject(post)
            
            PostFooter(showComments: $showComments)
                .environmentObject(post)
        }
        .overlay {
            if post.isSensitive {
                ZStack {
                    Rectangle()
                        .background(.ultraThinMaterial)
                    
                    Image(systemName: "eye.slash")
                        .foregroundStyle(.white)
                }
                .onTapGesture {
                    showAlert.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $showComments) {
            if let club = session.selectedGroup?.club {
                PostComments(club: club)
                    .environmentObject(post)
            }
        }
        .sheet(isPresented: $showMenu) {
            PostMenu(pinned: $pinned)
                .environmentObject(post)
                .environmentObject(feedModel)
                .presentationDetents([.height(250)])
        }
        .alert("Show Sensitive Content", isPresented: $showAlert) {
            Button(action: { post.isSensitive.toggle() }) {
                Text("Yes")
            }
            
            Button(action: {}) {
                Text("No")
            }
        } message: {
            Text("This post may contain sensitive content. Are you sure?")
        }
    }
}

struct PostHeader: View {
    
    @Binding var pinned: Bool
    @Binding var showMenu: Bool
    
    @EnvironmentObject private var post: Post
    @Environment(SessionStore.self) private var session
    
    private var isOrg: Bool {
        guard let selectedGroup = session.selectedGroup,
              selectedGroup.organization != nil else {
            return false
        }
        return true
    }
    
    private var userImageURL: URL? {
        guard let user = post.poster,
                let image = user.imageURL else {
            return nil
        }
        return generateImageURL(image)
    }
    
    private var orgImageURL: String {
        guard let club = session.selectedGroup?.club,
              let org = club.parent,
              let image = org.logo else {
            return GenerateImageURL("https://api.olympsis.com")
        }
        return GenerateImageURL(image)
    }
    
    private var username: String {
        guard let user = post.poster,
              let username = user.username,
              username != "" else {
            return "olympsis-user"
        }
        
        return username
    }
    
    private var orgName: String {
        guard let club = session.selectedGroup?.club,
              let org = club.parent,
              let name = org.name,
              name != "" else {
            return "Olympsis Organization"
        }
        return name
    }
    
    private func isPinned() -> Bool {
        guard let selectedGroup = session.selectedGroup else {
            return false
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                return false
            }
            if post.type == "announcement" {
                if let parent = club.parent {
                    return ((parent.pinnedPosts?.contains(where: { $0 == post.id })) != nil)
                }
            }
            return club.pinnedPosts.contains(post.id)
        } else {
            guard let org = selectedGroup.organization else {
                return false
            }
            return org.pinnedPosts.contains(where: { $0 == post.id })
        }
    }
    
    var body: some View {
        HStack {
            switch post.type {
            case "post":

                UserBadgeView(size: .small, imageURL: userImageURL)
                
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
                        Text(post.type.capitalized)
                            .font(.caption)
                            
                    }.padding(.leading, 5)
                } else {
                    UserBadgeView(size: .small, imageURL: userImageURL)
                    
                    VStack(alignment: .leading) {
                        Text(username)
                            .bold()
                    }
                    .padding(.leading, 5)
                }
            case "advertisement":
                EmptyView()
            default:
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
        .padding(.horizontal, 10)
        .task {
            self.pinned = isPinned()
        }
    }
}

struct PostBody: View {
    
    @State private var index: Int = 0
    @EnvironmentObject private var post: Post
    
    // post images links wrapped up in a url
    private var imagesURL: [URL] {
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
                                ImageLoadingView()
                            })
                            .resizable()
                            .setProcessor(postImageProcessor(size: CGSize(width: SCREEN_WIDTH*1.5, height: SCREEN_WIDTH*1.5)))
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: SCREEN_WIDTH)
                
                HStack {
                    Spacer()
                    ForEach(0..<imagesURL.count, id: \.self) { index in
                        Circle()
                            .frame(width: index == index ? 5 : 8,
                                   height: index == index ? 5 : 8)
                            .foregroundColor(index == self.index ? .blue : .gray)
                            .scaleEffect(index == index ? 1.2 : 1.0)
                            .animation(.easeInOut, value: index)
                    }
                    Spacer()
                }
                
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
    
    @Binding var showComments: Bool
    @State private var isLiked: Bool = false
    
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var post: Post
    @Environment(SessionStore.self) private var session
    
    private var likeCount: Int {
        return post.likes.count
    }
    
    private var timestamp: String {
        return calculateTimeAgo(from: post.createdAt)
    }
    
    private var hasExternalLink: Bool {
        guard let ext = self.post.externalLink,
              ext != "" else {
            return false
        }
        return true
    }
    
    private func like() async {
        guard let user = session.user,
            let uuid = user.uuid else {
            return
        }
        let dao = ReactionDao(uuid: uuid)
        guard let id = await session.postObserver.addLike(id: post.id, like: dao) else {
            return
        }
        let snippet = UserSnippet(uuid: uuid, username: user.username ?? "", imageURL: user.imageURL ?? "")
        let like = Reaction(id: id, uuid: uuid, user: snippet, createdAt: Date())
        isLiked = true
        post.likes.append(like)
    }
    
    private func removeLike() async {
        guard let user = session.user, let uuid = user.uuid,
              let like = post.likes.first(where: { $0.uuid == uuid }),
              await session.postObserver.deleteLike(id: post.id, likeID: like.id) else {
            return
        }
        post.likes.removeAll(where: {$0.uuid == like.uuid})
        isLiked = false
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
                        }
                        .padding(.trailing, 5)
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
                        .imageScale(.large)
                        .foregroundColor(.red)
                    : Image(systemName: "heart")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.leading)
                if likeCount > 0 {
                    Text("\(likeCount)")
                        .font(.caption)
                        .padding(.leading, -3)
                }
                Button(action:{ self.showComments.toggle() }){
                    Image(systemName: "bubble.right")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }
            }
            .padding(.all, 5)
            .task {
                if let user = session.user,
                      let uuid = user.uuid,
                      ((post.likes.first(where: { $0.uuid == uuid })) != nil) {
                    self.isLiked = true
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.Background.primary)
        }
    }
}

#Preview("Header") {
    PostHeader(pinned: .constant(false), showMenu: .constant(false))
        .environmentObject(POSTS[1])
        .environment(SessionStore())
}

#Preview("Body") {
    PostBody()
        .environmentObject(POSTS[1])
}

#Preview("Footer") {
    PostFooter(showComments: .constant(false))
        .environmentObject(POSTS[1])
        .environment(SessionStore())
}

#Preview {
    PostListItem(post: POSTS[1])
        .environment(SessionStore())
        .environmentObject(FeedViewModel())
}
