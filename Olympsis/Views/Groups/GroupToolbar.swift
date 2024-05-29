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
    
    @Binding var showEULA: Bool
    @Binding var showMenu: Bool
    @Binding var showNewPost: Bool
    @Binding var showSelector: Bool
    @Binding var showMessages: Bool
    @Binding var groupState: LOADING_STATE
    
    @EnvironmentObject private var session: SessionStore
    
    var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
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
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 35)
                                .foregroundStyle(Color("background"))
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(Color("foreground"))
                        }
                    }
                }
            } else {
                if let group = session.selectedGroup { // MARK: - Club Selected
                    if group.type == GROUP_TYPE.Club {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { self.showSelector.toggle() }) {
                                HStack {
                                    Text(group.club?.name ?? "")
                                        .font(.title)
                                        .bold()
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        
                                    Image(systemName: "chevron.down")
                                        .fontWeight(.bold)
                                        .imageScale(.small)
                                    Spacer()
                                }.frame(width: SCREEN_WIDTH/2)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                // You need to have accepted EULA before being able to make a post
                                guard acceptedEULA else {
                                    self.showEULA.toggle()
                                    return
                                }
                                self.showNewPost.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 40, height: 35)
                                        .foregroundStyle(Color("background"))
                                    Image(systemName: "plus.square.dashed")
                                        .foregroundStyle(Color("foreground"))
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMessages.toggle() }){
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 45, height: 35)
                                        .foregroundStyle(Color("background"))
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .foregroundStyle(Color("foreground"))
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMenu.toggle() }) {
                                AsyncImage(url: URL(string: GenerateImageURL(group.club?.logo ?? "https://api.olympsis.com"))){ image in
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
                                    Image(systemName: "chevron.down")
                                        .fontWeight(.bold)
                                        .imageScale(.small)
                                    Spacer()
                                }.frame(width: SCREEN_WIDTH/2)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { self.showNewPost.toggle() }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 40, height: 35)
                                        .foregroundStyle(Color("background"))
                                    Image(systemName: "plus.square.dashed")
                                        .foregroundStyle(Color("foreground"))
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMessages.toggle() }){
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 45, height: 35)
                                        .foregroundStyle(Color("background"))
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .foregroundStyle(Color("foreground"))
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{ self.showMenu.toggle() }) {
                                AsyncImage(url: URL(string: GenerateImageURL(group.organization?.logo ?? "https://api.olympsis.com"))){ image in
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
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 35)
                                .foregroundStyle(Color("background"))
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color("foreground"))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VStack {}.toolbar {
            GroupToolbar(showEULA: .constant(false), showMenu: .constant(false), showNewPost: .constant(false), showSelector: .constant(false), showMessages: .constant(false), groupState: .constant(.pending))
        }
        .environmentObject(SessionStore())
    }
}
