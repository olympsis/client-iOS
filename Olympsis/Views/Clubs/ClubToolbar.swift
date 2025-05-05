//
//  ClubToolbar.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/23.
//

import SwiftUI
import Kingfisher

struct ClubToolbar: ToolbarContent {
    
    @Binding var index: Int
    @Binding var showMenu: Bool
    @Binding var myClubs: [Club]
    @Binding var showNewPost: Bool
    @Binding var showMessages: Bool
    @Binding var status: LOADING_STATE
    @Environment(SessionStore.self) private var session
    
    private var selectedGroupType: GROUP_TYPE {
        guard let selectedGroup = session.selectedGroup else {
            return .Club
        }
        
        return selectedGroup.club != nil ? .Club : .Organization
    }
    
    private var selectedGroupName: String {
        guard let selectedGroup = session.selectedGroup,
                let name = selectedGroup.club?.name ?? selectedGroup.organization?.name else {
            return "Clubs"
        }
        
        return name
    }
    
    private var selecteGroupLogo: URL? {
        guard let selectedGroup = session.selectedGroup,
              let logo = selectedGroup.club?.logo ?? selectedGroup.organization?.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var body: some ToolbarContent {
        if status == .loading {
            ToolbarItem(placement: .navigationBarLeading) {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 150, height: 30)
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            }
        } else {
            if $myClubs.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Clubs")
                        .font(.largeTitle)
                        .bold()
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{ self.showMenu.toggle() }) {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .frame(width: 25, height: 15)
                            .foregroundColor(.primary)
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(Array(session.clubs)) { club in
                            Button(action:{
                                Task {
                                    guard let i = Array(session.clubs).firstIndex(where: { $0.id == club.id }) else {
                                        return
                                    }
                                    index = i
                                }
                            }
                            ){
                                Text(club.name)
                            }
                        }
                    } label: {
                        HStack {
                            VStack {
                                Text(selectedGroupName)
                                    .bold()
                                    .font(.title)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            Image(systemName: "chevron.down")
                                .fontWeight(.bold)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .imageScale(.small)
                            .foregroundColor(.primary)
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { self.showNewPost.toggle() }) {
                        Image(systemName: "plus.square.dashed")
                            .foregroundColor(Color("color-prime"))
                    }
                }
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button(action:{ self.showMessages.toggle() }){
                        Image(systemName: "bubble.right")
                            .foregroundColor(Color("color-prime"))
                    }
                    
                    Button(action:{ self.showMenu.toggle() }) {
                        GroupBadgeView(size: .small, type: selectedGroupType)
                    }
                }
            }
        }
    }
}
