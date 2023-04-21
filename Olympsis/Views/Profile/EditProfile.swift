//
//  EditProfile.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI
import PhotosUI

struct EditProfile: View {
    
    @Binding var imageURL: String
    
    @State private var bio: String = ""
    @State private var username: String = ""
    @State private var imageUrl: String?
    @State private var isPublic: Bool = true
    @State private var visibility: String = "public"

    @State private var selectedSports: [String] = [String]()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var uploadingStatus: LOADING_STATE = .pending
    
    @State var userObserver = UserObserver()
    @StateObject var uploadObserver = UploadObserver()
    
    
    @AppStorage("authToken") var authToken: String?
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func UpdateProfile() async -> Bool {
        
        // new image
        let imageId = UUID().uuidString
        
        if let data = selectedImageData {
            let url = await uploadObserver.UploadImage(location: "/profile-images", fileName: imageId, data: data)
            self.imageURL = "profile-images/\(imageId).jpeg"
            if url != "error" {
                if let user = session.user {
                    if let img = user.imageURL {
                        let res = await uploadObserver.DeleteObject(path: "/profile-image", name: GrabImageIdFromURL(img))
                        if !res {
                            print("failed to delete image")
                        }
                    }
                    let update = UpdateUserDataDao(_username: user.username, _bio: bio, _imageURL: self.imageURL, _isPublic: isPublic, _sports: selectedSports)
                    let res = await userObserver.UpdateUserData(update: update)
                    if res {
                        return true
                    }
                    
                }
            } else {
                print("failed to upload image")
                return false
            }
        } else {
            // if there is no new image data just update user data then
            if let user = session.user {
                let update = UpdateUserDataDao(_username: user.username, _bio: bio, _isPublic: isPublic, _sports: selectedSports)
                let res = await userObserver.UpdateUserData(update: update)
                if res {
                    return true
                }
                
            }
            return false
        }
        
        return false
    }
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    func compressImage(image: UIImage) -> Data? {
        var compressionQuality: CGFloat = 1.0 // start with maximum quality
        
        while let compressedData = image.jpegData(compressionQuality: compressionQuality),
              compressedData.count > 1000000 { // reduce quality until the size is less than 1 MB
            compressionQuality -= 0.1
        }
        
        return image.jpegData(compressionQuality: compressionQuality)
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
                                                    .foregroundColor(Color("primary-color"))
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
                                            .foregroundColor(Color("primary-color"))
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
                                        .foregroundColor(Color("primary-color"))
                            }.onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrive selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        let img = UIImage(data: data)
                                        selectedImageData = compressImage(image: img!)
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
                                .tint(Color("secondary-color"))
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
                                            .foregroundColor(Color("primary-color")).imageScale(.medium) : Image(systemName:"circle")
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
                            uploadingStatus = .loading
                            let res = await UpdateProfile()
                            await session.GenerateUpdatedUserData()
                            if res {
                                uploadingStatus = .success
                            } else {
                                uploadingStatus = .failure
                            }
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
        EditProfile(imageURL: .constant("")).environmentObject(SessionStore())
    }
}
