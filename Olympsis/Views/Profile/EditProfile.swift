//
//  EditProfile.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI
import PhotosUI

struct EditProfile: View {
    
    @State private var bio: String = ""
    @State private var username: String = ""
    @State private var imageUrl: String?
    @State private var isPublic: Bool = true
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @StateObject var userObserver = UserObserver()
    @StateObject var uploadObserver = UploadObserver()
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func UpdateProfile() async {
        
        guard bio.count > 5 else {
            return
        }
        
        // new image
        var imageId = ""
        
        if session.user?.imageURL == "" {
            imageId = UUID().uuidString
        } else {
            if let img = session.user?.imageURL {
                let substr = img.suffix(36)
                imageId = String(substr)
            }
        }
        
        // get upload link
        // upload image
        do{
            let url = try await GenerateImageUploadLink(id: imageId)
            if let data = selectedImageData {
                let res = try await uploadObserver.UploadObject(url: url, object: data)
                if !res {
                    print("Failed to upload image")
                }
            }
        } catch {
            print(error)
        }
        
        if let user = session.user {
            let update = UpdateUserDataDao(_username: user.username, _bio: bio, _imageURL: imageId, _clubs: user.clubs ?? [""], _isPublic: isPublic, _sports: user.sports ?? [""])
            let res = await userObserver.UpdateUserData(update: update)
            if res {
                await session.GenerateUpdatedUserData()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func GenerateImageUploadLink(id: String) async throws -> String {
        return try await uploadObserver.CreateUploadURL(folder: "profile-img", object: id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        VStack {
                            if let data = selectedImageData {
                                Image(uiImage: UIImage(data: data)!)
                                    .resizable()
                                    .clipShape(Circle())
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } else {
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
                                        ZStack {
                                            Image(systemName: "person")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(Color("primary-color"))
                                            Color.gray // Acts as a placeholder.
                                                .clipShape(Circle())
                                                .opacity(0.3)
                                        }
                                    }
                                }.frame(width: 100, height: 100)
                            }
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()) {
                                    Text("Edit picture")
                                        .foregroundColor(Color("primary-color"))
                            }.onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrive selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                    
                                    
                                }
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
                        HStack (alignment: .top){
                            Text("Bio")
                                .padding(.leading)
                                .padding(.top)
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
                                Text("Profile Visivility")
                            }.frame(width: SCREEN_WIDTH-30, height: 40)
                                .tint(Color("secondary-color"))
                            Text("Allow users not on your friends list to see your profile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                    }
                    Spacer()
                    
                    Button(action:{
                        Task {
                            await UpdateProfile()
                        }
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("primary-color"))
                                .frame(width: 150, height: 40)
                            Text("Save Changes")
                                .foregroundColor(.white)
                        }
                    }.padding(.top, 50)
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
