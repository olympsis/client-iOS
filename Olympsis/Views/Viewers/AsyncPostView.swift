//
//  AsyncPostView.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/3/24.
//

import os
import SwiftUI

struct AsyncPostView: View {
    
    @State public var postId: String
    @State private var post: Post?
    @State private var state: VIEW_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "async_post_view")
    
    @MainActor
    private func fetchPost() async {
        state = .loading
        guard let post = await session.postObserver.getPost(id: postId) else {
            state = .failure
            log.error("Failed to fetch post:\(postId, privacy: .public)")
            return
        }
        self.post = post
        state = .success
    }
    
    var body: some View {
        ScrollView {
            switch state {
            case .pending, .loading:
                ProgressView()
                    .padding(.vertical, 100)
            case .success:
                if let post {
                    PostListItem(post: post)
                }
            case .failure:
                VStack {
                    Image("illustrations/sorry")
                        .resizable()
                        .frame(width: 250, height: 250)
                    Text("Failed to get post.")
                        .fontWeight(.bold)
                    Button(action: { Task { await fetchPost() }}) {
                        Text("Try again")
                    }
                }.padding(.vertical, 100)
            }
        }
        .task {
            await fetchPost()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { Task {
                     await fetchPost()
                } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .navigationTitle("Post")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AsyncPostView(postId: "")
            .environmentObject(SessionStore())
    }
}
