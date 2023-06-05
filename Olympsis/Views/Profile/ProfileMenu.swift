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
                    Button(action:{ }) {
                        HStack {
                            Image(systemName: "bell")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Notification Settings")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ }) {
                        HStack {
                            Image(systemName: "lifepreserver")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Help")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ }) {
                        HStack {
                            Image(systemName: "lock")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("About")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ Task {
                        await session.logout()
                        self.presentationMode.wrappedValue.dismiss()
                    }}) {
                        HStack {
                            Image(systemName: "door.left.hand.open")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.red)
                            Text("Log out")
                                .foregroundColor(.red)
                                .bold()
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ self.showDeleteView.toggle() }) {
                        HStack {
                            Image(systemName: "delete.forward")
                                .imageScale(.medium)
                                .padding(.leading)
                                .foregroundColor(.red)
                            Text("Delete Account")
                                .foregroundColor(.red)
                                .bold()
                            Spacer()
                        }.modifier(MenuButton())
                    }
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
            .fullScreenCover(isPresented: $showDeleteView) {
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
