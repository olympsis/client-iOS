//
//  EditProfileButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EditProfileButton: View {
   
    @State var showEditProfile = false
    @ObservedObject var userObserver: UserObserver
    @Binding var imageURL: String
    
    var body: some View {
        VStack(alignment: .center){
            Button(action:{self.showEditProfile.toggle()}){
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 35)
                        .foregroundColor(Color("secondary-color"))
                        .frame(width: 250)
                        .opacity(0.5)
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .bold()
                        .font(.callout)
                }
            }.fullScreenCover(isPresented: $showEditProfile) {
                EditProfile(imageURL: $imageURL, userObserver: userObserver)
            }
        }.frame(width: SCREEN_WIDTH)
    }
}

struct EditProfileButton_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileButton(userObserver: UserObserver(), imageURL: .constant(""))
    }
}
