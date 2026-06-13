//
//  PostCreator.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/18/24.
//

import os
import SwiftUI

struct PostCreator: View {
    
    var type: NEW_POST_TYPE
    var groupId: String
    
    @FocusState private var bodyFocused: Bool
    @State private var mediaPickerVisible: Bool = false
    @State private var postViolationVisible: Bool = false
    @StateObject private var viewModel: NewPostManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    @EnvironmentObject private var feedModel: FeedViewModel
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "post_creator_view")
    
    init(type: NEW_POST_TYPE, groupId: String) {
        self.type = type
        self.groupId = groupId
        
        switch type {
        case .Post:
            self._viewModel = StateObject(wrappedValue:
                NewPostManager(type: .Post)
            )
        case .Announcement:
            self._viewModel = StateObject(wrappedValue:
                NewPostManager(type: .Announcement)
            )
        }
    }
    
    private func showMediaPicker() {
        bodyFocused = false
        mediaPickerVisible.toggle()
    }
    
    private func createPost() async throws {
        guard let user = session.user,
              let post = try await viewModel.createPost(groupId: groupId, user: user) else {
            return
        }
        feedModel.posts[groupId]?.append(post)
        dismiss()
    }
    
    private func handlePostCreation() {
        guard viewModel.status != .loading else { return }
        
        _ = Task {
            do {
                try await createPost()
            } catch MediaUploadError.innapropriateContent {
                self.postViolationVisible.toggle()
            } catch MediaUploadError.unexpected(let reason) {
                log.error("Failed to create post: \(reason)")
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action:{ handlePostCreation() }){
                    LoadingButton(text: "Create", status: $viewModel.status)
                }
                .frame(maxWidth: 150)
                .disabled(viewModel.status == .loading ? true : false)
            }.padding(.horizontal)
            
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
                        .foregroundStyle(Color(Color.Background.secondary))
                    
                    TextEditor(text: $viewModel.body)
                        .focused($bodyFocused)
                        .padding(.horizontal)
                        .frame(height: 200)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color(Color.Background.secondary))
                }
                
                HStack {
                    Spacer()
//                    Button(action: { }) {
//                        Image(systemName: "chart.bar.fill")
//                            .imageScale(.large)
//                    }
//                    .padding(.all)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10)
//                            .opacity(0.3)
//                            .foregroundStyle(Color(Color.gray))
//                    }
//                    
//                    Button(action: { }) {
//                        Image(systemName: "calendar")
//                            .imageScale(.large)
//                    }
//                    .padding(.all)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10)
//                            .opacity(0.3)
//                            .foregroundStyle(Color(Color.gray))
//                    }
                    
                    Button(action: { showMediaPicker() }) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
                    .padding(.all)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .opacity(0.3)
                            .foregroundStyle(Color(Color.gray))
                    }
                    
                    
                }.padding(.horizontal)
            }
            .sheet(isPresented: $postViolationVisible, onDismiss: { dismiss() }, content: {
                PostMediaViolation()
            })
            .fullScreenCover(isPresented: $mediaPickerVisible, content: {
                MediaPicker(pickerType: .newPost) { images in
                    viewModel.selectedImages = images
                }
            })
        }
    }
}

#Preview {
    PostCreator(type: .Post, groupId: "")
        .environment(SessionStore())
        .environmentObject(FeedViewModel())
}
