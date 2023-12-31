//
//  PostMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/17/23.
//

import SwiftUI

struct PostMenu: View {
    
    @State var post: Post
    @Binding var posts: [Post]
    @Binding var pinned: Bool
    @StateObject private var uploadObserver = UploadObserver()
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var isPosterOrAdmin: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let group = session.selectedGroup else {
            return false
        }
        if group.type == GROUP_TYPE.Club.rawValue {
            guard let type = post.type,
                  type == "post",
                  let club = group.club,
                  let members = club.members,
                  let member = members.first(where: { $0.uuid == uuid }),
                  member.role != "member" else {
                if post.type == "post" {
                    return (post.poster == uuid)
                } else {
                    return false
                }
            }
        } else {
            return true
        }
        return false
    }
    
    var isPinned: Bool {
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
    
    func pinPost() async {
        guard let selectedGroup = session.selectedGroup else {
            return
        }
        if selectedGroup.type == GROUP_TYPE.Club.rawValue {
            guard let club = selectedGroup.club,
                  let id = club.id,
                  let postId = post.id else {
                return
            }
            let resp = await session.clubObserver.pinPost(id: id, postId: postId)
            if resp {
                club.pinnedPostId = postId
                pinned = true
            }
            return
        } else {
            guard let org = selectedGroup.organization,
                  let id = org.id,
                  let postId = post.id else {
                return
            }
            let resp = await session.orgObserver.pinPost(id: id, postId: postId)
            if resp {
                org.pinnedPostId = postId
                pinned = true
            }
            return
        }
    }
    
    func unPinPost() async {
        guard let selectedGroup = session.selectedGroup else {
            return
        }
        if selectedGroup.type == GROUP_TYPE.Club.rawValue {
            guard let club = selectedGroup.club,
                  let id = club.id else {
                return
            }
            let resp = await session.clubObserver.unPinPost(id: id)
            if resp {
                club.pinnedPostId = nil
                pinned = false
                posts = posts
            }
            return
        } else {
            guard let org = selectedGroup.organization,
                  let id = org.id else {
                return
            }
            let resp = await session.orgObserver.unPinPost(id: id)
            if resp {
                org.pinnedPostId = nil
                pinned = false
                posts = posts
            }
        }
    }
    
    func deletePost() async {
        guard let id = post.id else {
            return
        }
        
        let res = await session.postObserver.deletePost(postID: id)
        guard res == true,
            let images = post.images else {
            session.posts.removeAll(where: { $0.id == post.id })
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        // delete images
        for image in images {
            let _ = await uploadObserver.DeleteObject(path: "/feed-images", name: GrabImageIdFromURL(image))
        }
        
        // remove post
        posts.removeAll(where: { $0.id == post.id })
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.bottom, 1)
                .padding(.top, 7)
            
            Button(action:{}) {
                HStack {
                    Image(systemName: "exclamationmark.bubble")
                        .imageScale(.large)
                        .padding(.leading)
                        .foregroundColor(.primary)
                    Text("Report Post")
                        .foregroundColor(.primary)
                    Spacer()
                }.modifier(MenuButton())
            }
            
            if isPosterOrAdmin {
                if pinned {
                    Button(action:{ Task { await unPinPost() }}) {
                        HStack {
                            Image(systemName: "pin")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Unpin Post")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                } else {
                    Button(action:{ Task { await pinPost() }}) {
                        HStack {
                            Image(systemName: "pin.fill")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Pin Post")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                }
                Button(action:{ Task { await deletePost() }}) {
                    HStack {
                        Image(systemName: "trash")
                            .imageScale(.large)
                            .padding(.leading)
                            .foregroundColor(.red)
                        Text(" Delete Post")
                            .foregroundColor(.red)
                        Spacer()
                    }.modifier(MenuButton())
                }
            }
            Spacer()
        }.task {
            pinned = isPinned
        }
    }
}

struct PostMenu_Previews: PreviewProvider {
    static var previews: some View {
        PostMenu(post: POSTS[0], posts: .constant(POSTS), pinned: .constant(false)).environmentObject(SessionStore())
    }
}
