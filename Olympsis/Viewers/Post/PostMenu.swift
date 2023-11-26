//
//  PostMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/17/23.
//

import SwiftUI

struct PostMenu: View {
    
    @State var post: Post
    @StateObject private var uploadObserver = UploadObserver()
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var isPosterOrAdmin: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let group = session.selectedGroup,
              let club = group.club,
              let members = club.members else {
            return false
        }
        
        guard let member = members.first(where: { $0.uuid == uuid }),
              member.role == "member" else {
            return true
        }
        
        return (post.poster == uuid)
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
        session.posts.removeAll(where: { $0.id == post.id })
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
        }
    }
}

struct PostMenu_Previews: PreviewProvider {
    static var previews: some View {
        PostMenu(post: POSTS[0]).environmentObject(SessionStore())
    }
}
