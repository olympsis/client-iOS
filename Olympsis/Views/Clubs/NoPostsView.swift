//
//  NoPostsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct NoPostsView: View {
    
    @State var club: Club
    
    @State private var isLoading        = true
    @State private var showCreatePost   = false
    
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text("There are no posts")
                .padding(.top)
                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT/1.2)
            Button(action: { self.showCreatePost.toggle() }){
                ZStack {
                    Circle()
                        .foregroundColor(Color("secondary-color"))
                        .frame(width: 50)
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }.padding(.trailing)
                .padding(.bottom, 30)
                .fullScreenCover(isPresented: $showCreatePost, onDismiss: {
                    isLoading = true
                    Task {
                        let posts = await postObserver.fetchPosts(clubId:club.id)
                        await MainActor.run(body: {
                            for post in posts {
                                session.posts.append(post)
                            }
                        })
                    }
                    isLoading = false
                }) { CreateNewPost(clubId: club.id) }
        }
    }
}


struct NoPostsView_Previews: PreviewProvider {
    static var previews: some View {
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, isVisible: true, members: [Member](), rules: ["No fighting"])
        NoPostsView(club: club)
    }
}
