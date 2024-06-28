//
//  PostMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/17/23.
//

import SwiftUI

struct PostMenu: View {
    
    @Binding var pinned: Bool
    
    @State private var isBlocked: Bool = false
    @State private var showReport: Bool = false
    @State private var showBlocking: Bool = false
    
    @StateObject private var uploadObserver = UploadObserver()
    
    @EnvironmentObject private var post: Post
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var feedModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    
    var isPosterOrAdmin: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let group = session.selectedGroup else {
            return false
        }
        if group.type == GROUP_TYPE.Club {
            guard let type = post.type,
                  type == "post",
                  let club = group.club,
                  let member = club.members.first(where: { $0.user?.uuid == uuid }) else {
                if post.type == "post" {
                    return (post.poster?.uuid == uuid)
                } else {
                    return false
                }
            }
            if member.role != "member" {
                return true
            } else {
                return (post.poster?.uuid == uuid)
            }
        } else {
            return true
        }
    }
    
    var isPinned: Bool {
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
            return ((club.pinnedPosts?.contains(where: { $0 == post.id ?? ""})) != nil)
        } else {
            guard let org = selectedGroup.organization,
                  let pinnedPosts = org.pinnedPosts else {
                return false
            }
            return pinnedPosts.contains(where: { $0 == post.id })
        }
    }
    
    func pinPost() async {
        guard let selectedGroup = session.selectedGroup else {
            return
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club,
                  let id = club.id,
                  let postId = post.id else {
                return
            }
            let resp = await session.clubObserver.pinPost(id: id, postId: postId)
            if resp {
                club.pinnedPosts?.append(postId)
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
                org.pinnedPosts?.append(postId)
                pinned = true
            }
            return
        }
    }
    
    func unPinPost() async {
        guard let selectedGroup = session.selectedGroup else {
            return
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club,
                  let id = club.id else {
                return
            }
            let resp = await session.clubObserver.unPinPost(id: id)
            if resp {
                club.pinnedPosts?.removeAll(where: { $0 == id})
                pinned = false
            }
            return
        } else {
            guard let org = selectedGroup.organization,
                  let id = org.id else {
                return
            }
            let resp = await session.orgObserver.unPinPost(id: id)
            if resp {
                org.pinnedPosts?.removeAll(where: { $0 == id })
                pinned = false
            }
        }
    }
    
    func deletePost() async {
        guard let selectedGroup = session.selectedGroup,
            let id = post.id else {
            return
        }
        
        if selectedGroup.type == .Club {
            guard let id = selectedGroup.club?.id,
                  await session.postObserver.deletePost(postID: id) else {
                return
            }

            if let images = post.images {
                // delete images
                for image in images {
                    let _ = await uploadObserver.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(image))
                }
            }
            
            // remove post
            feedModel.posts[id]?.removeAll(where: { $0.id == post.id })
            dismiss()
        } else {
            guard let id = selectedGroup.organization?.id,
                  await session.postObserver.deletePost(postID: id) else {
                return
            }
            
            if let images = post.images {
                // delete images
                for image in images {
                    let _ = await uploadObserver.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(image))
                }
            }
            
            // remove post
            feedModel.posts[id]?.removeAll(where: { $0.id == post.id })
            dismiss()
        }
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.bottom, 1)
                .padding(.top, 7)
            
            if isPosterOrAdmin {
                if pinned {
                    MenuButton(icon: Image(systemName: "pin.fill"), text: "Unpin Post", action: {
                        Task {
                            await unPinPost()
                        }
                    })
                } else {
                    MenuButton(icon: Image(systemName: "pin"), text: "Pin Post", action: {
                        Task {
                            await pinPost()
                        }
                    })
                }
            }
            
            MenuButton(icon: Image(systemName: "exclamationmark.bubble.fill"), text: "Report Post") {
                showReport.toggle()
            }.fullScreenCover(isPresented: $showReport, content: {
                PostReportView(post: post)
            })
            
            if !isBlocked {
                MenuButton(icon: Image(systemName: "person.slash"), text: "Block User", action:  {
                    showBlocking.toggle()
                }, type: .destructive)
                .sheet(isPresented: $showBlocking, content: {
                    if let poster = post.poster {
                        UserBlockingConfirmation(user: poster, onComplete: { resp in
                            if resp {
                                self.post.isSensitive = true
                            }
                        })
                        .presentationDetents([.height(450), .medium])
                    }
                })
            }
            
            if isPosterOrAdmin {
                MenuButton(icon: Image(systemName: "trash.fill"), text: "Remove Post", action:  {
                    Task {
                        await deletePost()
                    }
                }, type: .destructive)
            }
            Spacer()
        }.task {
            pinned = isPinned
        }
    }
}

#Preview("Post Menu") {
    PostMenu(pinned: .constant(false))
        .environmentObject(POSTS[0])
        .environmentObject(SessionStore())
        .environmentObject(FeedViewModel())
}
