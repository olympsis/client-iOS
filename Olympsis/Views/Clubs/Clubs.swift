//
//  Clubs.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI
import AlertToast

struct Clubs: View {
    
    @State private var index: Int = 0
    @State private var showNewPost = false
    @State private var showMenu: Bool = false
    @State private var showMessages: Bool = false
    @State private var status: LOADING_STATE = .loading
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        NavigationView {
            VStack {
                if status == .loading {
                    ClubLoadingTemplateView()
                } else {
                    if $session.clubs.isEmpty {
                        ClubsList()
                            .sheet(isPresented: $showMenu) {
                                NoClubMenu(status: $status)
                                    .presentationDetents([.height(250)])
                            }
                    } else {
                        MyClubView(club: $session.clubs[index], index: $index, showMenu: $showMenu, showNewPost: $showNewPost, showMessages: $showMessages)
                    }
                }
            }
            .toolbar {
                ClubToolbar(index: $index, showMenu: $showMenu, myClubs: $session.clubs, showNewPost: $showNewPost, showMessages: $showMessages, status: $status)
            }
            .task {
                status = .success
            }
        }
    }
}

struct Clubs_Previews: PreviewProvider {
    static var previews: some View {
        Clubs().environmentObject(SessionStore())
    }
}
