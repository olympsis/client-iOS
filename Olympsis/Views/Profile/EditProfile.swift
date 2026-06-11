//
//  EditProfile.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
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
    
    @State private var showMediaPicker: Bool = false
    @State private var showImageCropper: Bool = false
    @State private var showSportsPicker: Bool = false
    @State private var showHometownPicker: Bool = false
    
    @State private var testCroppedImage: UIImage?
    @State private var showTestCroppedImage: Bool = false
    
    @State private var hometown: CLLocationCoordinate2D?
    
    
    @State private var selectedSports: Set<String> = []
    
    @State private var selectedPhoto: UIImage?
    @State private var selectedPhotoData: Data?
    
    @State private var croppedPhotoData: Data?
    
    @State private var status: LOADING_STATE = .pending
    @StateObject private var photoViewModel = PhotoPickerViewModel()
    
    private var cacheService: CacheService = CacheService()
    private var userObserver: UserObserver = UserObserver()
    private var uploadObserver: UploadObserver = UploadObserver()
    
    @Environment(SessionStore.self) private var session
    
    @Environment(\.dismiss) private var dismiss
    
    var log = Logger(subsystem: "com.olympsis.client", category: "edit_profile_view")
    
    /**
     Just a function to handle displaying to the user that the action has failed
     */
    private func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.status = .pending
        }
    }
    
    private func updateProfile() async {
        var imageURL: String = ""
        status = .loading
        // new image
        let imageId = UUID().uuidString
        
        // check for updated image
        guard let data = selectedPhotoData else {
            guard let user = session.user else {
                handleFailure()
                return
            }
            
            var coords: GeoJSON?
            if (latitude != 0 && longitude != 0) {
                coords = GeoJSON(type: "Point", coordinates: [longitude, latitude])
            }

            let update = UserDao(username: user.username, bio: bio, sports: Array(selectedSports), hometown: coords)
            guard let res = await userObserver.updateUserData(update: update) else {
                handleFailure()
                return
            }
            
            session.user = res
            cacheService.cacheUser(user: res)
            status = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
            return
        }
        
        guard (await uploadObserver.UploadImage(location: "/olympsis-profile-images", fileName: imageId, data: data)) != nil else {
            handleFailure()
            return
        }
        
        imageURL = "profile-images/\(imageId).jpeg"
        
        guard let user = session.user else {
            handleFailure()
            return
        }
        
        if let img = user.imageURL {
            // delete old picture
            _ = await uploadObserver.DeleteObject(path: "/olympsis-profile-images", name: GrabImageIdFromURL(img))
        }
        
        var coords: GeoJSON?
        if (latitude != 0 && longitude != 0) {
            coords = GeoJSON(type: "Point", coordinates: [longitude, latitude])
        }

        // update user data
        let update = UserDao(username: user.username, bio: bio, imageURL: imageURL, sports: Array(selectedSports), hometown: coords)
        guard let resp = await userObserver.updateUserData(update: update) else {
            handleFailure()
            return
        }
        
        session.user = resp
        cacheService.cacheUser(user: resp)
        status = .success
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                                    Color(Color.Background.secondary) // Acts as a placeholder.
                                        .clipShape(Circle())
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(Color.Foreground.default)
                                }.frame(width: 100, height: 100)
                            } else {
                                ZStack {
                                    Color(Color.Background.secondary) // Acts as a placeholder.
                                        .clipShape(Circle())
                                    ProgressView()
                                }.frame(width: 100, height: 100)
                            }
                        }.frame(width: 100, height: 100)
                    } else {
                        ZStack {
                            Color(Color.Background.secondary)
                                .clipShape(Circle())
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(Color.Foreground.default)
                        }.frame(width: 100, height: 100)
                    }
                }
                
                Button(action: { self.showMediaPicker.toggle() }) {
                    Text(String(localized: "edit-picture", table: "Profile"))
                }.fullScreenCover(isPresented: $showMediaPicker, content: {
                    MediaPicker(pickerType: .profile) { images in
                        if let img = images.first {
                            selectedPhoto = img
                            selectedPhotoData = img.jpegData(compressionQuality: 0.5)
                        }
                    }
                })
                
            }.padding(.bottom, 30)
                .padding(.top)
            
            // MARK: - Username Text Field
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(String(localized: "username", table: "Profile"))
                    Text(String(localized: "username-sub-text", table: "Profile"))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                TextField("\(session.user?.username ?? "error")", text: $username)
                    .padding(.leading)
                    .disabled(true)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                            .foregroundColor(Color(Color.Background.secondary))
                    }
                    .padding(.top, 5)
            }.padding(.horizontal)
                .padding(.bottom, 15)
            
            // MARK: - Bio Text Box
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(String(localized: "bio", table: "Profile"))
                    Text(String(localized: "bio-sub-text", table: "Profile"))
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
                            .foregroundColor(Color(Color.Background.secondary))
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
                    Text(String(localized: "profile-visibility", table: "Profile"))
                }.frame(width: SCREEN_WIDTH-30, height: 40)
                    .tint(Color("color-secnd"))
                    .onChange(of: isPublic) { _, newValue in
                        if newValue {
                            visibility = "public"
                        } else {
                            visibility = "private"
                        }
                    }
                Text(String(localized: "profile-visibility-sub-text", table: "Profile"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }.padding(.horizontal)
            
            // MARK: - Sports Picker
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(String(localized: "sports", table: "Profile"))
                    HStack(alignment: .top) {
                        Text(String(localized: "sports-sub-text", table: "Profile"))
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
                                    Text(sport.capitalized)
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
                        .foregroundColor(Color(Color.Background.secondary))
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .sheet(isPresented: $showSportsPicker, content: {
                MultiSportsPicker(sports: session.sports, selectedSports: $selectedSports)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
            
            // MARK: - Hometown Picker
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(String(localized: "hometown", table: "Profile"))
                    HStack(alignment: .top) {
                        Text(String(localized: "hometown-sub-text", table: "Profile"))
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }.foregroundStyle(.gray)
                }
                Button(action: { self.showHometownPicker.toggle() }) {
                    if (latitude == 0 && longitude == 0 || session.user?.hometown == nil) {
                        Text("N/A")
                    } else {
                        Text("\(city), \(state) (\(country))")
                    }
                }.frame(maxWidth: .infinity, idealHeight: 40)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 40)
                        .foregroundColor(Color(Color.Background.secondary))
                }
            }.padding(.horizontal)
                .padding(.vertical, 15)
                .fullScreenCover(isPresented: $showHometownPicker, content: {
                    ProfileHometownPicker(city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude)
                })
            
            
            Spacer()
            
        }
        .background(Color.Background.primary)
        .navigationTitle(String(localized: "edit-profile", table: "Profile"))
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action:{ dismiss() }){
                    Text(String(localized: "cancel", table: "General"))
                        .foregroundColor(.primary)
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action:{
                        Task {
                            await updateProfile()
                        }
                    }){
                        LoadingButton(text: String(localized: "save", table: "General"), width: 50, status: $status)
                            .fixedSize()
                    }
                    .buttonStyle(.plain)
                    .disabled(status != .pending)
                }.sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action:{
                        Task {
                            await updateProfile()
                        }
                    }){
                        LoadingButton(text: String(localized: "save", table: "General"), width: 50, status: $status)
                            .fixedSize()
                    }
                    .buttonStyle(.plain)
                    .disabled(status != .pending)
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
                    hometown = CLLocationCoordinate2D(latitude: home.coordinates[1], longitude: home.coordinates[0])
                    getPlacemark(from: CLLocationCoordinate2D(latitude: home.coordinates[1], longitude: home.coordinates[0])) { placemark in
                        if let placemark = placemark {
                            let city = placemark.locality ?? ""
                            let state = placemark.administrativeArea ?? ""
                            let country = placemark.country ?? ""
                            
                            self.city = city
                            self.state = state
                            self.country = country
                        } else {
                            #if DEBUG
                            print("Unable to get placemark information")
                            #endif
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfile()
            .environment(SessionStore())
    }
}
