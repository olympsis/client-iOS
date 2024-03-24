//
//  PostViewer.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/21/24.
//

import SwiftUI

struct PostViewer: View {
    
    @State var post: Post
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                PostView(post: post, posts: $session.posts)
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action:{ dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color("foreground"))
                    }
                }
            }
        }
    }
}

#Preview {
    PostViewer(post: POSTS[1])
        .environmentObject(SessionStore())
}
