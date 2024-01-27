//
//  CreateNewPost.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI
import PhotosUI

struct NewPost: View {
    
    @State var club: Club
    @Binding var posts: [Post]
    
    @FocusState private var bodyFocus: Bool
    
    @State private var status: LOADING_STATE = .pending
    @StateObject private var manager: NewPostManager = NewPostManager(type: .Post)
    
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
              let id = club.id else {
            return
        }
        
        // generate dao
        guard var dao = manager.GenerateNewPostData(groupId: id) else {
            handleFailure()
            return
        }
        
        // upload image
        if manager.selectedImageData != nil {
            guard let img = await self.manager.UploadImage(data: manager.selectedImageData!) else {
                handleFailure()
                return
            }
            dao.images = [img]
        }
        
        // create post and get the id
        guard let postId = await session.postObserver.createPost(dao: dao) else {
            if let images = dao.images {
                _ = await manager.DeleteImages(images: images)
            }
            handleFailure()
            return
        }
        
        // generate local post data
        guard let post = manager.GenerateNewPost(id: postId, user: user, dao: dao) else {
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
                            Rectangle()
                                .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                                .opacity(0.3)
                            TextEditor(text: $manager.body)
                                .scrollContentBackground(.hidden)
                                .tint(Color("color-prime"))
                                .focused($bodyFocus)
                        }
                    }.frame(width: SCREEN_WIDTH-25, height: 200)
                        .padding(.top)
                    HStack {
                        Text("Image")
                            .bold()
                        Spacer()
                        if manager.selectedImageData == nil {
                            PhotosPicker(
                                selection: $manager.selectedItem,
                                matching: .images,
                                photoLibrary: .shared()) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 100, height: 30)
                                            .foregroundColor(Color("color-prime"))
                                        Text("upload")
                                            .foregroundColor(.white)
                                            .frame(height: 30)
                                            .font(.caption)
                                            .textCase(.uppercase)
                                    }
                                }.onChange(of: manager.selectedItem) { newItem in
                                    Task {
                                        bodyFocus = false
                                        // Retrive selected asset in the form of Data
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            withAnimation(.easeIn){
                                                manager.selectedImageData = data
                                            }
                                        }
                                    }
                                }
                        } else {
                            Button(action:{
                                withAnimation(.easeOut){
                                    manager.selectedImageData = nil
                                    manager.selectedItem = nil
                                }
                            }){
                                Image(systemName: "x.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color("color-prime"))
                            }
                        }
                    }.frame(width: SCREEN_WIDTH-25, height: 50)
                    if let imgData = manager.selectedImageData {
                        let img = UIImage(data: imgData)
                        if let i = img {
                            Image(uiImage: i)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                                .padding(.horizontal)
                        }
                        
                    }
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
                .navigationTitle("New Post")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        NewPost(club: CLUBS[0], posts: .constant(POSTS))
            .environmentObject(SessionStore())
    }
}
