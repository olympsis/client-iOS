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
    
    private let uploadService = UploadService()
    
    @EnvironmentObject private var post: Post
    @Environment(SessionStore.self) private var session
    @EnvironmentObject private var feedModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var selectedGroup: GroupSelection? {
        return session.groupsManager.selected
    }
    
    private var isAdmin: Bool {
        guard let user = session.user,
              let userID = user.userID,
              let group = selectedGroup else {
            return false
        }
        if group.type == GROUP_TYPE.Club {
            guard post.type == "post",
                  let club = group.club,
                  let member = club.members.first(where: { $0.user?.userID == userID }) else {
                return false
            }
            return member.role != "member"
        } else {
            return true
        }
    }
    
    private var isPoster: Bool {
        guard let user = session.user,
              let userID = user.userID else {
            return false
        }
        return post.poster?.userID == userID
    }
    
    private var isPinned: Bool {
        guard let selectedGroup = selectedGroup else {
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
            return (club.pinnedPosts.contains(where: { $0 == post.id }))
        } else {
            guard let org = selectedGroup.organization else {
                return false
            }
            return org.pinnedPosts.contains(where: { $0 == post.id })
        }
    }
    
    private func pinPost() async {
        guard let selectedGroup = selectedGroup else {
            return
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                return
            }
            let resp = await session.clubObserver.pinPost(id: club.id, postId: post.id)
            if resp {
                club.pinnedPosts.append(post.id)
                pinned = true
            }
            return
        } else {
            guard let org = selectedGroup.organization else {
                return
            }
            let resp = await session.orgObserver.pinPost(id: org.id, postId: post.id)
            if resp {
                org.pinnedPosts.append(post.id)
                pinned = true
            }
            return
        }
    }
    
    private func unPinPost() async {
        guard let selectedGroup = selectedGroup else {
            return
        }
        if selectedGroup.type == GROUP_TYPE.Club {
            guard let club = selectedGroup.club else {
                return
            }
            let resp = await session.clubObserver.unPinPost(id: club.id)
            if resp {
                club.pinnedPosts.removeAll(where: { $0 == club.id})
                pinned = false
            }
            return
        } else {
            guard let org = selectedGroup.organization else {
                return
            }
            let resp = await session.orgObserver.unPinPost(id: org.id)
            if resp {
                org.pinnedPosts.removeAll(where: { $0 == org.id })
                pinned = false
            }
        }
    }
    
    private func deletePost() async {
        guard let selectedGroup = selectedGroup else {
            return
        }
        
        if selectedGroup.type == .Club {
            guard let clubID = selectedGroup.club?.id,
                  await session.postService.deletePost(postID: post.id) else {
                return
            }

            if let images = post.images {
                // delete images
                for image in images {
                    let _ = await uploadService.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(image))
                }
            }

            // remove post
            feedModel.posts[clubID]?.removeAll(where: { $0.id == post.id })
            dismiss()
        } else {
            guard let orgID = selectedGroup.organization?.id,
                  await session.postService.deletePost(postID: post.id) else {
                return
            }
            
            if let images = post.images {
                // delete images
                for image in images {
                    let _ = await uploadService.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(image))
                }
            }
            
            // remove post
            feedModel.posts[orgID]?.removeAll(where: { $0.id == post.id })
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
            
            if isAdmin {
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
                PostReportView()
                    .environmentObject(post)
            })
            
            if !isPoster && !isBlocked {
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
            
            if isAdmin || isPoster {
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
        .environment(SessionStore())
        .environmentObject(FeedViewModel())
}
