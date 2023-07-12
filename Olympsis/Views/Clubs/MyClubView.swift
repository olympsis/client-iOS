//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MyClubView: View {
    
    @Binding var club: Club
    @Binding var index: Int
    @Binding var showMenu: Bool
    @Binding var showNewPost: Bool
    @Binding var showMessages: Bool

    @State private var showPostMenu = false
    @State private var showCreatePost = false
    @State private var status: LOADING_STATE = .loading
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            PostsView(club: $club, index: $index, showNewPost: $showNewPost)
        }
        .fullScreenCover(isPresented: $showMenu) {
            ClubMenu(club: $club, index: $index)
        }
        .fullScreenCover(isPresented: $showMessages) {
            Messages(club: $club)
        }
    }
    
}

struct MyClubView_Previews: PreviewProvider {
    static var previews: some View {
        MyClubView(club: .constant(CLUBS[0]), index: .constant(0), showMenu: .constant(false), showNewPost: .constant(false), showMessages: .constant(false)).environmentObject(SessionStore())
    }
}
