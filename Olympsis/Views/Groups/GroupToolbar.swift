//
//  GroupToolbar.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import SwiftUI

/// A toolbar content generator to generate different toolbars based on wether the user has any clubs and organizations.
/// Helps manages how to transition between these states and keep track of them all.
struct GroupToolbar: ToolbarContent {
    
    @Binding var showMenu: Bool
    @Binding var showNewPost: Bool
    @Binding var showSelector: Bool
    @Binding var showMessages: Bool
    @Binding var groupState: LOADING_STATE
    @EnvironmentObject private var session: SessionStore
    
    func retryFetchingClubData() {
        groupState = .loading
    }
    
    var body: some ToolbarContent {
        switch session.clubsState {
        case .loading:
            ToolbarItem(placement: .topBarLeading) {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 150, height: 30)
            }
            
            ToolbarItem(placement: .topBarTrailing){
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            }
        case .success, .pending:
            if session.selectedGroup == nil {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Clubs")
                        .font(.title)
                        .bold()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action:{ self.showMenu.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            } else {
                if let group = session.selectedGroup { // MARK: - Club Selected
                    if group.type == "club" {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { self.showSelector.toggle() }) {
                                HStack {
                                    Text(group.club?.name ?? "")
                                        .font(.title)
                                        .bold()
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                        .frame(width: SCREEN_WIDTH/2)
                                    Image(systemName: "chevron.down")
                                        .fontWeight(.bold)
                                        .imageScale(.small)
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { self.showNewPost.toggle() }) {
                                Image(systemName: "plus.square.dashed")
                                    .foregroundColor(Color("color-prime"))
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMessages.toggle() }){
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .foregroundColor(Color("color-prime"))
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMenu.toggle() }) {
                                AsyncImage(url: URL(string: GenerateImageURL(group.club?.imageURL ?? "https://api.olympsis.com"))){ image in
                                    image.resizable()
                                        .clipShape(Circle())
                                        .frame(width: 40, height: 40)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        
                                } placeholder: {
                                    Circle()
                                        .foregroundColor(.gray)
                                        .opacity(0.3)
                                        .frame(width: 40)
                                }
                            }
                        }
                    } else { // MARK: - Organization Selected
                        
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { self.showSelector.toggle() }) {
                                HStack {
                                    Text(group.organization?.name ?? "")
                                        .font(.title)
                                        .bold()
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                        .frame(width: SCREEN_WIDTH/2)
                                    Image(systemName: "chevron.down")
                                        .fontWeight(.bold)
                                        .imageScale(.small)
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { self.showNewPost.toggle() }) {
                                Image(systemName: "plus.square.dashed")
                                    .foregroundColor(Color("color-prime"))
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMenu.toggle() }) {
                                AsyncImage(url: URL(string: GenerateImageURL(group.organization?.imageURL ?? "https://api.olympsis.com"))){ image in
                                    image.resizable()
                                        .clipShape(Circle())
                                        .frame(width: 40, height: 40)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        
                                } placeholder: {
                                    Circle()
                                        .foregroundColor(.gray)
                                        .opacity(0.3)
                                        .frame(width: 40)
                                }
                            }
                        }
                    }
                }
            }
        case .failure:
            ToolbarItem(placement: .topBarLeading) {
                Text("Clubs")
                    .font(.title)
                    .bold()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if (groupState == .loading) {
                    ProgressView()
                } else {
                    Button(action:{ retryFetchingClubData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VStack {}.toolbar {
            GroupToolbar(showMenu: .constant(false), showNewPost: .constant(false), showSelector: .constant(false), showMessages: .constant(false), groupState: .constant(.pending))
        }
        .environmentObject(SessionStore())
    }
}
