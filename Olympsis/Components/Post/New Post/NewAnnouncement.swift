//
//  CreateNewAnnouncement.swift
//  Olympsis
//
//  Created by Joel on 12/1/23.
//

import SwiftUI
import PhotosUI

struct NewAnnouncement: View {
    
    @State var organization: Organization
    @Binding var posts: [Post]
    
    @FocusState private var bodyFocus: Bool
    
    @State private var status: LOADING_STATE = .pending
    @StateObject private var manager: NewPostViewModel = NewPostViewModel(type: .Announcement)
    
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    private func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    private func handleSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    func CreateNewPost() async {
        guard manager.body != "" || manager.body.count > 5 else {
            return
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        status = .loading
        guard let user = session.user,
              let id = organization.id else {
            return
        }
        
        // generate dao
        guard var dao = manager.generateNewPostData(groupId: id) else {
            handleFailure()
            return
        }
        
        // upload image
//        if manager.selectedImageData != nil {
//            guard let img = await self.manager.uploadImage(data: manager.selectedImageData!) else {
//                handleFailure()
//                return
//            }
//            dao.images = [img]
//        }
        
        // create post and get the id
        guard let postId = await session.postObserver.createPost(dto: dao) else {
            if let images = dao.images {
                _ = await manager.deleteImages(images: images)
            }
            handleFailure()
            return
        }
        
        // generate local post data
        guard let post = manager.generateNewPost(id: postId, user: user, dto: dao) else {
            handleFailure()
            dismiss()
            return
        }
        
        await MainActor.run {
            self.posts.append(post)
            handleSuccess()
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(alignment: .leading){
                        Text("What's up?")
                            .bold()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("background"))
                            TextEditor(text: $manager.body)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.primary)
                                .focused($bodyFocus)
                        }
                    }.frame(height: 200)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    // MARK: - External Link
                    VStack(alignment: .leading){
                        Text("External Link")
                            .font(.title3)
                            .bold()
                        Text("Link for more information")
                            .font(.subheadline)
                        
                        TextField("", text: $manager.externalLink)
                            .padding(.leading)
                            .modifier(InputField())
                            .contextMenu {
                                Button(action: {
                                    if let pasteboardString = UIPasteboard.general.string {
                                        manager.externalLink = pasteboardString
                                    }
                                }) {
                                    Text("Paste")
                                    Image(systemName: "doc.on.clipboard")
                                }
                            }
                    }.padding(.horizontal)
                        .padding(.top)
                    
                    HStack {
                        Text("Image")
                            .bold()
                        Spacer()
                    }.frame(height: 50)
                        .padding(.horizontal)
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement:.navigationBarLeading){
                        Button(action:{ dismiss() }){
                            Image(systemName: "chevron.left")
                                .tint(Color("color-prime"))
                        }
                    }
                    ToolbarItem(placement:.navigationBarTrailing){
                        Button(action:{
                            Task{
                                await CreateNewPost()
                            }
                        }){ LoadingButton(text: "Create", width: 70, status: $status) }
                            .disabled(status == .loading ? true : false)
                    }
                }
                .navigationTitle("New Announcement")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    NewAnnouncement(organization: ORGANIZATIONS[0], posts: .constant(POSTS))
}
