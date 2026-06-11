//
//  EditProfileButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EditProfileButton: View {
   
    @State var showEditProfile = false
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        VStack(alignment: .center){
            NavigationLink(destination: EditProfile().environment(session)) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 250, height: 35)
                        .foregroundColor(Color(Color.Background.secondary))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.border, lineWidth: 1)
                        }
                    
                    Text(String(localized: "edit-profile", table: "Profile"))
                        .foregroundColor(Color.Foreground.default)
                        .bold()
                        .font(.callout)
                }
            }
        }.frame(width: SCREEN_WIDTH)
    }
}

#Preview {
    NavigationStack {
        EditProfileButton()
            .environment(SessionStore())
    }
}
