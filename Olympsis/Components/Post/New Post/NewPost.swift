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
    @StateObject private var viewModel: NewPostViewModel = NewPostViewModel(type: .Post)
    
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
        guard viewModel.body != "" || viewModel.body.count > 5 else {
            return
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        status = .loading
        guard let user = session.user,
              let id = club.id else {
            return
        }
        
        // generate dao
        guard var dao = viewModel.generateNewPostData(groupId: id) else {
            handleFailure()
            return
        }
        
//        // upload image
//        if viewModel.selectedImageData != nil {
//            guard let img = await self.viewModel.uploadImage(data: viewModel.selectedImageData!) else {
//                handleFailure()
//                return
//            }
//            dao.images = [img]
//        }
        
        // create post and get the id
        guard let postId = await session.postObserver.createPost(dto: dao) else {
            if let images = dao.images {
                _ = await viewModel.deleteImages(images: images)
            }
            handleFailure()
            return
        }
        
        // generate local post data
        guard let post = viewModel.generateNewPost(id: postId, user: user, dto: dao) else {
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
                            TextEditor(text: $viewModel.body)
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
                    }.frame(width: SCREEN_WIDTH-25, height: 50)
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
