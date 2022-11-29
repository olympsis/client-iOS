//
//  EditProfile.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EditProfile: View {
    
    @State private var bio: String = ""
    @State private var username: String = ""
    @State private var imageUrl: String?
    @State private var isPublic: Bool = true
    
    @StateObject var userObserver = UserObserver()
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func UpdateProfile() async {
        guard bio.count > 5 else {
            return
        }
        if let user = session.user {
            let update = UpdateUserDataDao(_username: user.username, _bio: bio, _imageURL: user.imageURL!, _clubs: user.clubs!, _isPublic: isPublic, _sports: user.sports!)
            let res = await userObserver.UpdateUserData(update: update)
            if res {
                await session.generateUpdatedUserData()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        VStack {
                            AsyncImage(url: URL(string: session.user?.imageURL ?? "")){ phase in
                                if let image = phase.image {
                                        image // Displays the loaded image.
                                            .resizable()
                                            .clipShape(Circle())
                                            .scaledToFit()
                                    } else if phase.error != nil {
                                        Color.red // Indicates an error.
                                            .clipShape(Circle())
                                            .opacity(0.15)
                                    } else {
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    }
                            }.frame(width: 100, height: 100)
                            
                            Button(action: {}){
                                Text("Edit picture")
                                    .foregroundColor(Color("primary-color"))
                            }
                            
                        }.padding(.bottom, 30)
                            .padding(.top)
                        HStack {
                            Text("Username")
                                .padding(.leading)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 40)
                                    .padding(.trailing)
                                    .foregroundColor(.primary)
                                    .opacity(0.15)
                                TextField("\(session.user?.username ?? "error")", text: $username)
                                    .padding(.leading)
                                    .disabled(true)
                            }
                        }
                        HStack {
                            Text("Bio")
                                .padding(.leading)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 80)
                                    .padding(.trailing)
                                    .foregroundColor(.primary)
                                    .opacity(0.15)
                                TextEditor(text: $bio)
                                    .padding(.leading)
                                    .frame(height: 80)
                                    .scrollContentBackground(.hidden)
                                     
                            }
                        }.task {
                            if let user = session.user {
                                bio = user.bio
                                isPublic = user.isPublic
                            }
                            
                        }
                        
                        VStack(alignment: .leading){
                            Toggle(isOn: $isPublic) {
                                Text("Public")
                            }.frame(width: SCREEN_WIDTH-30, height: 40)
                                .tint(Color("secondary-color"))
                            Text("Allow users not on your friends list to see your profile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                    }
                    Spacer()
                }.navigationTitle("Edit Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                                Text("Cancel")
                                    .foregroundColor(.primary)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action:{
                                Task {
                                    await UpdateProfile()
                                }
                            }){
                                Text("Done")
                                    .foregroundColor(Color("primary-color"))
                            }
                        }
                }
            }
            
        }
    }
}

struct EditProfile_Previews: PreviewProvider {
    static var previews: some View {
        EditProfile().environmentObject(SessionStore())
    }
}
