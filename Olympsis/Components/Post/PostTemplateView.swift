//
//  PostTemplateView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/14/23.
//

import SwiftUI

struct PostTemplateView: View {
    
    @State private var pinned: Bool = false
    @State private var showMenu: Bool = false
    @State private var showComments: Bool = false
    
    @StateObject private var post: Post
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var feedModel: FeedViewModel
    
    init() {
        self._post = StateObject(wrappedValue: POSTS[0])
    }
    
    var body: some View {
        VStack {
            PostHeader(pinned: $pinned, showMenu: $showMenu)
                .environmentObject(post)
            
            Rectangle()
                .foregroundStyle(.gray)
                .opacity(0.7)
                .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH)
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
            
            PostFooter(showComments: $showComments)
                .environmentObject(post)
            
        }.redacted(reason: .placeholder)
    }
}

#Preview {
    PostTemplateView()
        .environmentObject(SessionStore())
}
