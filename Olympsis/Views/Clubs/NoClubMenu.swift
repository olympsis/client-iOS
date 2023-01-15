//
//  NoClubMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import SwiftUI

struct NoClubMenu: View {
    @State private var showNewClub: Bool = false
    @State private var showInvites: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 35, height: 5)
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                    .padding(.top, 7)
                
                Button(action:{self.showNewClub.toggle()}) {
                    HStack {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .padding(.leading)
                            .foregroundColor(.primary)
                        VStack(alignment: .leading){
                            Text("Create a Club")
                                .foregroundColor(.primary)
                            Text("Where athletes come together")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }.modifier(MenuButton())
                }.fullScreenCover(isPresented: $showNewClub) {
                    CreateNewClub()
                }
            }
        }
    }
}

struct NoClubMenu_Previews: PreviewProvider {
    static var previews: some View {
        NoClubMenu()
    }
}
