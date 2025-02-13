//
//  EditProfileButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EditProfileButton: View {
   
    @State var showEditProfile = false
    
    var body: some View {
        VStack(alignment: .center){
            Button(action:{self.showEditProfile.toggle()}){
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 250, height: 35)
                        .foregroundColor(Color(Color.Background.secondary))
                    Text("Edit Profile")
                        .foregroundColor(Color("foreground"))
                        .bold()
                        .font(.callout)
                }
            }
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfile()
            }
        }.frame(width: SCREEN_WIDTH)
    }
}

struct EditProfileButton_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileButton()
    }
}
