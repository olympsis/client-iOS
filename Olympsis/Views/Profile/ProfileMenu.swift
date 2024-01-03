//
//  ProfileMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI

struct ProfileMenu: View {
    
    @State var showDeleteView = false
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    MenuButton(icon: Image(systemName: "bell.fill"), text: "Notification Settings")
                        .padding(.top)
                    
                    MenuButton(icon: Image(systemName: "lifepreserver.fill"), text: "Help")
                    
                    MenuButton(icon: Image(systemName: "lock.fill"), text: "Privacy Policy")
                        
                    MenuButton(icon: Image(systemName: "info.circle.fill"), text: "About")
                    
                    MenuButton(icon: Image(systemName: "door.left.hand.open"), text: "Logout", action: {
                        Task {
                            await session.logout()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }, type: .destructive)
                    
                    MenuButton(icon: Image(systemName: "delete.forward"), text: "Delete Account", action: {
                        self.showDeleteView.toggle()
                    }, type: .destructive)
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $showDeleteView, onDismiss: { self.presentationMode.wrappedValue.dismiss() }) {
                    DeleteAccountView()
                }
            }
        }
    }
}

struct ProfileMenu_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMenu()
    }
}
