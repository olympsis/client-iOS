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
    @State private var isPublic: Bool = true
    @State private var visibility: String = "public"

    @State private var selectedSports: [String] = [String]()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var uploadingStatus: LOADING_STATE = .pending
    
    @State var userObserver = UserObserver()
    @StateObject var uploadObserver = UploadObserver()
    
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func UpdateProfile() async {
        var imageURL: String = ""
        uploadingStatus = .loading
        // new image
        let imageId = UUID().uuidString
        
        // check for updated image
        guard let data = selectedImageData else {
            guard let user = session.user else {
                uploadingStatus = .failure
                return
            }
            let update = User(username: user.username, bio: bio, sports: selectedSports)
            let res = await userObserver.UpdateUserData(update: update)
            
            guard res == true else {
                uploadingStatus = .failure
                return
            }
            uploadingStatus = .success
            return
        }
        
        let res = await uploadObserver.UploadImage(location: "/profile-images", fileName: imageId, data: data)
        
        guard res == true else {
            uploadingStatus = .failure
            return
        }
        
        imageURL = "profile-images/\(imageId).jpeg"
        
        guard var user = session.user else {
            return
        }
        
        if let img = user.imageURL {
            // delete old picture
            _ = await uploadObserver.DeleteObject(path: "/profile-images", name: GrabImageIdFromURL(img))
        }
        
        // update user data
        let update = User(username: user.username, bio: bio, imageURL: imageURL, sports: selectedSports)
        let resp = await userObserver.UpdateUserData(update: update)
        
        guard resp == true else {
            uploadingStatus = .failure
            return
        }
        
        user.imageURL = imageURL
        session.user = user
        uploadingStatus = .success
    }
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        VStack {
                            if let data = selectedImageData {
                                if let img = UIImage(data: data) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .clipShape(Circle())
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                            } else {
                                if let img = session.user?.imageURL {
                                    AsyncImage(url: URL(string: GenerateImageURL(img))){ phase in
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
                                                    .foregroundColor(Color("color-prime"))
                                                Color.gray // Acts as a placeholder.
                                                    .clipShape(Circle())
                                                    .opacity(0.3)
                                            }
                                        }
                                    }.frame(width: 100, height: 100)
                                } else {
                                    ZStack {
                                        Image(systemName: "person")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color("color-prime"))
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    }.frame(width: 100, height: 100)
                                }
                            }
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()) {
                                    Text("Edit picture")
                                        .foregroundColor(Color("color-prime"))
                            }.onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrive selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        let img = UIImage(data: data)
                                        selectedImageData = img!.jpegData(compressionQuality: 0.5)
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
                                bio = user.bio ?? ""
                                isPublic = (user.visibility == "private" ? false : true)
                            }
                            
                        }
                        
                        VStack(alignment: .leading){
                            Toggle(isOn: $isPublic) {
                                Text("Profile Visivility")
                            }.frame(width: SCREEN_WIDTH-30, height: 40)
                                .tint(Color("color-secnd"))
                                .onChange(of: isPublic) { newValue in
                                    if newValue {
                                        visibility = "public"
                                    } else {
                                        visibility = "private"
                                    }
                                }
                            Text("Allow users not on your friends list to see your profile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Sports:")
                                .bold()
                            ForEach(SPORT.allCases, id: \.self){ _sport in
                                HStack {
                                    Button(action: {updateSports(sport: _sport.rawValue)}){
                                        isSelected(sport: _sport.rawValue) ? Image(systemName: "circle.fill")
                                            .foregroundColor(Color("color-prime")).imageScale(.medium) : Image(systemName:"circle")
                                            .foregroundColor(.primary).imageScale(.medium)
                                    }
                                    Text(_sport.rawValue)
                                        .font(.body)
                                    Spacer()
                                }.padding(.top)
                            }
                        }.padding(.leading)
                            .padding(.top)
                        
                    }
                    Spacer()
                    
                    Button(action:{
                
                        Task {
                            await UpdateProfile()
                            let _ = await session.generateUserData()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                    }){
                        LoadingButton(text: "Save Changes", width: 150, status: $uploadingStatus)
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
                    }
                    .task {
                        if let usr = session.user {
                            if let sports = usr.sports {
                                selectedSports = sports
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
