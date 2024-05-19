//
//  PostCreator.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/18/24.
//

import SwiftUI

struct PostCreator: View {
    
    var type: NEW_POST_TYPE
    var groupId: String
    @Binding var posts: [Post]
    
    @FocusState private var bodyFocused: Bool
    @State private var showMediaPicker: Bool = false
    @StateObject private var viewModel: NewPostViewModel
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    init(type: NEW_POST_TYPE, groupId: String, posts: Binding<[Post]>) {
        self.type = type
        self.groupId = groupId
        self._posts = Binding(projectedValue: posts)
        
        switch type {
        case .Post:
            self._viewModel = StateObject(wrappedValue:
                NewPostViewModel(type: .Post)
            )
        case .Announcement:
            self._viewModel = StateObject(wrappedValue:
                NewPostViewModel(type: .Announcement)
            )
        }
    }
    
    func createPost() async {
        guard let user = session.user,
              let post = await viewModel.createPost(groupId: groupId, user: user) else {
            return
        }
        
        posts.append(post)
        dismiss()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
                
                Spacer()
                
                Button(action:{ Task { await createPost() }}){
                    LoadingButton(text: "Create", width: 70, status: $viewModel.status)
                }
                .disabled(viewModel.status == .loading ? true : false)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack {
                    if (viewModel.selectedImages.count > 0) {
                        HStack (spacing: 10) {
                            ForEach(viewModel.selectedImages, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .scaledToFit()
                            }
                        }.padding(.horizontal)
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("background"))
                    
                    TextEditor(text: $viewModel.body)
                        .focused($bodyFocused)
                        .padding(.horizontal)
                        .onTapGesture {
                            if (viewModel.body == "Write a caption") {
                                viewModel.body = ""
                            }
                        }
                        .foregroundStyle(viewModel.body == "Write a caption" ? .gray : .primary)
                        .frame(height: 200)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("background"))
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        bodyFocused = false
                        showMediaPicker.toggle()
                    }) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
                    .padding(.all)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color("background"))
                    }
                    .fullScreenCover(isPresented: $showMediaPicker, content: {
                        MediaPicker(pickerType: .newPost) { images in
                            viewModel.selectedImages = images
                        }
                    })
                }.padding(.horizontal)
            }
        }
    }
}

#Preview {
    PostCreator(type: .Post, groupId: "", posts: .constant([Post]()))
}
