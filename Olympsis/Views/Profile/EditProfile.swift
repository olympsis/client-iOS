//
//  EditProfile.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI
import PhotosUI

struct EditProfile: View {
    
    @State private var showSportsPicker: Bool = false
    @State private var showHometownPicker: Bool = false
    
    @EnvironmentObject private var viewModel: ProfileViewModel
    @EnvironmentObject private var session: SessionStore
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack {
                        if let data = viewModel.selectedPhotoData {
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
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("Edit Picture")
                                    .foregroundColor(Color("color-prime"))
                        }.onChange(of: viewModel.selectedPhotoItem) { newItem in
                            Task {
                                // Retrive selected asset in the form of Data
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    let img = UIImage(data: data)
                                    viewModel.selectedPhotoData = img!.jpegData(compressionQuality: 0.5)
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
                        TextField("\(session.user?.username ?? "error")", text: $viewModel.username)
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
                        TextEditor(text: $viewModel.bio)
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
                            viewModel.bio = user.bio ?? ""
                            viewModel.isPublic = (user.visibility == "private" ? false : true)
                        }
                        
                    }
                    
                    // MARK: - Profile Visibility Toggle
                    VStack(alignment: .leading){
                        Toggle(isOn: $viewModel.isPublic) {
                            Text("Profile Visibility")
                        }.frame(width: SCREEN_WIDTH-30, height: 40)
                            .tint(Color("color-secnd"))
                            .onChange(of: viewModel.isPublic) { newValue in
                                if newValue {
                                    viewModel.visibility = "public"
                                } else {
                                    viewModel.visibility = "private"
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
                            if !viewModel.selectedSports.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack(alignment: .center) {
                                        ForEach(Array(viewModel.selectedSports), id: \.self) { sport in
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
                            ProfileSportsPicker(selectedSports: $viewModel.selectedSports)
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
                            if (viewModel.hometown == nil) {
                                Text("N/A")
                            } else {
                                Text("\(viewModel.city), \(viewModel.state) (\(viewModel.country))")
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
                            ProfileHometownPicker()
                                .environmentObject(viewModel)
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
                                    await viewModel.UpdateProfile()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        dismiss()
                                    }
                                }
                            }){
                                LoadingButton(text: "Save", width: 50, height: 25, status: viewModel.$status)
                            }
                        }
                    }
                    .task {
                        if let usr = session.user {
                            if let sports = usr.sports {
                                for sport in sports {
                                    viewModel.selectedSports.insert(sport)
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
            .environmentObject(ProfileViewModel())
    }
}
