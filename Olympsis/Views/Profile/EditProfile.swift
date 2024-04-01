//
//  EditProfile.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI
import PhotosUI

struct EditProfile: View {
    
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    
    
    @State private var bio: String = ""
    @State private var username: String = ""
    @State private var isPublic: Bool = true
    @State private var visibility: String = "public"
    
    @State private var showSportsPicker: Bool = false
    @State private var showHometownPicker: Bool = false
    
    @State private var hometown: CLLocationCoordinate2D?
    
    
    @State private var selectedSports: Set<String> = []
    
    @State private var selectedPhotoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @State private var status: LOADING_STATE = .pending
    
    private var cacheService: CacheService = CacheService()
    private var userObserver: UserObserver = UserObserver()
    private var uploadObserver: UploadObserver = UploadObserver()
    
    @EnvironmentObject private var session: SessionStore
    
    @Environment(\.dismiss) private var dismiss
    
    func UpdateProfile() async {
        var imageURL: String = ""
        status = .loading
        // new image
        let imageId = UUID().uuidString
        
        // check for updated image
        guard let data = selectedPhotoData else {
            guard let user = session.user else {
                status = .failure
                return
            }
            
            var coords: [Double]?
            if (latitude != 0 && longitude != 0) {
                coords = [latitude, longitude]
            }
            
            let update = UserDao(username: user.username, bio: bio, hometown: coords, sports: Array(selectedSports))
            let res = await userObserver.UpdateUserData(update: update)
            
            guard res == true else {
                status = .failure
                return
            }
            
            session.user?.bio = bio
            session.user?.visibility = visibility
            session.user?.sports = Array(selectedSports)
            session.user?.hometown = [latitude, longitude]
            guard let usr = session.user else {
                status = .success
                return
            }
            cacheService.cacheUser(user: usr)
            status = .success
            return
        }
        
        let res = await uploadObserver.UploadImage(location: "/olympsis-profile-images", fileName: imageId, data: data)
        
        guard res == true else {
            status = .failure
            return
        }
        
        imageURL = "profile-images/\(imageId).jpeg"
        
        guard var user = session.user else {
            return
        }
        
        if let img = user.imageURL {
            // delete old picture
            _ = await uploadObserver.DeleteObject(path: "/olympsis-profile-images", name: GrabImageIdFromURL(img))
        }
        
        var coords: [Double]?
        if (latitude != 0 && longitude != 0) {
            coords = [latitude, longitude]
        }
        
        // update user data
        let update = UserDao(username: user.username, bio: bio, imageURL: imageURL, hometown: coords, sports: Array(selectedSports))
        let resp = await userObserver.UpdateUserData(update: update)
        
        guard resp == true else {
            status = .failure
            return
        }
        
        session.user?.bio = bio
        session.user?.visibility = visibility
        session.user?.sports = Array(selectedSports)
        session.user?.imageURL = imageURL
        session.user?.hometown = [latitude, longitude]
        guard let usr = session.user else {
            status = .success
            return
        }
        cacheService.cacheUser(user: usr)
        status = .success
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        if let data = selectedPhotoData {
                            if let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .clipShape(Circle())
                                    .scaledToFill()
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
                                        ZStack {
                                            Color("background") // Acts as a placeholder.
                                                .clipShape(Circle())
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundStyle(Color("foreground"))
                                        }.frame(width: 100, height: 100)
                                    } else {
                                        ZStack {
                                            Color("background") // Acts as a placeholder.
                                                .clipShape(Circle())
                                            ProgressView()
                                        }.frame(width: 100, height: 100)
                                    }
                                }.frame(width: 100, height: 100)
                            } else {
                                ZStack {
                                    Color("background")
                                        .clipShape(Circle())
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(Color("foreground"))
                                }.frame(width: 100, height: 100)
                            }
                        }
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("Edit Picture")
                                    .foregroundColor(Color("color-prime"))
                        }.onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                // Retrive selected asset in the form of Data
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    let img = UIImage(data: data)
                                    selectedPhotoData = img!.jpegData(compressionQuality: 0.5)
                                }
                            }
                        }
                        
                    }.padding(.bottom, 30)
                        .padding(.top)
                    
                    // MARK: - Username Text Field
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Username")
                            Text("What would you like your nickname to be?")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        TextField("\(session.user?.username ?? "error")", text: $username)
                            .padding(.leading)
                            .disabled(true)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 40)
                                    .foregroundColor(Color("background"))
                            }
                            .padding(.top, 5)
                    }.padding(.horizontal)
                        .padding(.bottom, 15)
                    
                    // MARK: - Bio Text Box
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Bio")
                            Text("Share some information about yourself")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        TextEditor(text: $bio)
                            .padding(.horizontal, 5)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 100)
                                    .foregroundColor(Color("background"))
                            }
                    }.padding(.horizontal)
                        .padding(.bottom, 15)
                    .task {
                        if let user = session.user {
                            bio = user.bio ?? ""
                            isPublic = (user.visibility == "private" ? false : true)
                        }
                        
                    }
                    
                    // MARK: - Profile Visibility Toggle
                    VStack(alignment: .leading){
                        Toggle(isOn: $isPublic) {
                            Text("Profile Visibility")
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
                    
                    // MARK: - Sports Picker
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Sports")
                            HStack(alignment: .top) {
                                Text("What athletic activites are you into?")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }.foregroundStyle(.gray)
                        }
                        Button(action: {
                            self.showSportsPicker.toggle()
                        }) {
                            if !selectedSports.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack(alignment: .center) {
                                        ForEach(Array(selectedSports), id: \.self) { sport in
                                            Text(sport)
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundStyle(Color("color-prime"))
                                                    }
                                        }
                                    }
                                }.scrollIndicators(.never)
                            } else {
                                Text("N/A")
                            }
                        }.frame(maxWidth: .infinity, idealHeight: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundColor(Color("background"))
                        }
                    }.padding(.horizontal)
                        .padding(.top)
                        .fullScreenCover(isPresented: $showSportsPicker, content: {
                            ProfileSportsPicker(selectedSports: $selectedSports)
                                .presentationDetents([.medium])
                        })
                    
                    // MARK: - Hometown Picker
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Hometown")
                            HStack(alignment: .top) {
                                Text("Where do you call home? We need a fall back location if we can’t find you through your location.")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }.foregroundStyle(.gray)
                        }
                        Button(action: { self.showHometownPicker.toggle() }) {
                            if (latitude == 0 && longitude == 0 && session.user?.hometown == nil) {
                                Text("N/A")
                            } else {
                                Text("\(city), \(state) (\(country))")
                            }
                        }.frame(maxWidth: .infinity, idealHeight: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundColor(Color("background"))
                        }
                    }.padding(.horizontal)
                        .padding(.vertical, 15)
                        .fullScreenCover(isPresented: $showHometownPicker, content: {
                            ProfileHometownPicker(city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude)
                        })
                    
                    
                    Spacer()
                    
                }.navigationTitle("Edit Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action:{ dismiss() }){
                                Text("Cancel")
                                    .foregroundColor(.primary)
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action:{
                                Task {
                                    await UpdateProfile()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        dismiss()
                                    }
                                }
                            }){
                                LoadingButton(text: "Save", width: 50, status: $status)
                            }
                        }
                    }
                    .task {
                        if let usr = session.user {
                            if let sports = usr.sports {
                                for sport in sports {
                                    selectedSports.insert(sport)
                                }
                            }
                            
                            if let home = usr.hometown {
                                hometown = CLLocationCoordinate2D(latitude: home[0], longitude: home[1])
                                getPlacemark(from: CLLocationCoordinate2D(latitude: home[0], longitude: home[1])) { placemark in
                                    if let placemark = placemark {
                                        let city = placemark.locality ?? ""
                                        let state = placemark.administrativeArea ?? ""
                                        let country = placemark.country ?? ""
                                        
                                        self.city = city
                                        self.state = state
                                        self.country = country
                                    } else {
                                        print("Unable to get placemark information")
                                    }
                                }
                            }
                        }
                        
                    }
            }
        }
    }
}

struct EditProfile_Previews: PreviewProvider {
    static var previews: some View {
        EditProfile()
            .environmentObject(SessionStore())
    }
}
