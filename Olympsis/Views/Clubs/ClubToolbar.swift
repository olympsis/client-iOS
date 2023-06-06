//
//  ClubToolbar.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/23.
//

import SwiftUI

struct ClubToolbar: ToolbarContent {
    
    @Binding var index: Int
    @Binding var showMenu: Bool
    @Binding var myClubs: [Club]
    @Binding var showNewPost: Bool
    @Binding var showMessages: Bool
    @Binding var status: LOADING_STATE
    @EnvironmentObject private var session: SessionStore
    
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
                    Text(myClubs[index].name!)
                        .font(.title)
                        .bold()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(width: SCREEN_WIDTH/2)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { self.showNewPost.toggle() }) {
                        Image(systemName: "plus.square.dashed")
                            .foregroundColor(Color("primary-color"))
                    }
                }
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button(action:{ self.showMessages.toggle() }){
                        Image(systemName: "bubble.right")
                            .foregroundColor(Color("primary-color"))
                    }
                    
                    Button(action:{ self.showMenu.toggle() }) {
                        AsyncImage(url: URL(string: GenerateImageURL((myClubs[index].imageURL ?? "")))){ image in
                            image.resizable()
                                .clipShape(Circle())
                                .frame(width: 30, height: 30)
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                
                        } placeholder: {
                            Circle()
                                .foregroundColor(.gray)
                                .opacity(0.3)
                                .frame(width: 30)
                        }
                    }
                }
            }
        }
    }
}
