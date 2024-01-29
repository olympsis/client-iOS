//
//  NewClub.swift
//  Olympsis
//
//  Created by Joel on 11/13/23.
//

import os
import SwiftUI
import PhotosUI

struct NewClub: View {
    enum CREATE_ERROR: Error {
        case unexpected
        case noName
    }
    
    @State private var state: LOADING_STATE = .pending
    @State private var clubName: String = ""
    @State private var description: String = ""
    @State private var sport: String = "soccer"
    @State private var userSports = [String]()
    @State private var imageURL: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showToast = false
    
    @StateObject var uploadObserver = UploadObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "create_new_club_view")
    
    func UploadImage() async {
        if let data = selectedImageData {
            // new image
            let imageId = UUID().uuidString
            let _ = await uploadObserver.UploadImage(location: "/olympsis-club-images", fileName: imageId, data: data)
            self.imageURL = "olympsis-club-images/\(imageId).jpeg"
        }
    }
    
    func Validate() -> CREATE_ERROR? {
        if clubName == "" || clubName.count < 3  || clubName.count > 25 {
            return .noName
        }
        return nil
    }
    
    func CreateClub() async {
        
        // validate view
        let val = Validate()
        guard val == nil else {
            log.error("err")
            state = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                state = .pending
            }
            return
        }
        
        state = .loading
        
        // upload image if there is one
        if selectedImageData != nil {
            await UploadImage()
        }
        
        // grab current location and create club
        let geoCoder = CLGeocoder()
        guard let location = session.locationManager.location else {
            return
        }
        let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
        do {
            let pk = try await geoCoder.reverseGeocodeLocation(l)
            guard let country = pk.first?.country,
                  let state = pk.first?.administrativeArea,
                  let city = pk.first?.locality else {
                return
            }
            let club = Club(id: nil, parent: nil, type: "club", name: clubName, description: description, sport: sport, city: city, state: state, country: country, imageURL: imageURL, imageGallery: nil, visibility: "public", members: nil, rules: nil, pinnedPostId: nil, createdAt: nil)
            
            // create new club
            let resp = try await session.clubObserver.createClub(club: club)
            let group = GroupSelection(type: GROUP_TYPE.Club, club: resp, organization: nil, posts: nil)
            session.groups.append(group)

            showToast = true
            self.state = .success
            dismiss()
        } catch {
            self.state = .failure
            log.error("\(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack (alignment: .leading){
                    VStack (alignment: .leading){
                        Text("Club Name:")
                            .font(.title3)
                            .bold()
                        Text("What your club will be known by")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextField("", text: $clubName)
                            .padding(.leading)
                    }.frame(height: 40)
                    VStack(alignment: .leading){
                        Text("Description:")
                            .font(.title3)
                            .bold()
                        .padding(.top)
                        Text("What your club is about?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextEditor(text: $description)
                            .scrollContentBackground(.hidden)
                        .frame(height: 200)
                    }
                    
                    // MARK: - Sports picker
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Sport")
                                .font(.title3)
                            .bold()
                            Text("The sport your club will focus on")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        ZStack {
                            Rectangle()
                                .foregroundColor(.primary)
                                .opacity(0.1)
                                .frame(height: 40)
                            Picker(selection: $sport, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                                ForEach(SPORT.allCases, id: \.rawValue) { sport in
                                    Text(sport.rawValue).tag(sport.rawValue)
                                }
                            }.frame(width: SCREEN_WIDTH/2)
                                .tint(Color("color-prime"))
                        }
                    }.padding(.top)
                        .frame(width: SCREEN_WIDTH-25)
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Club Image")
                                    .font(.title3)
                                .bold()
                                Text("Upload an image for your club")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if selectedImageData == nil {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()) {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 100, height: 30)
                                                .foregroundColor(Color("color-prime"))
                                            Text("upload")
                                                .foregroundColor(.white)
                                                .frame(height: 30)
                                                .font(.caption)
                                                .textCase(.uppercase)
                                        }
                                    }.onChange(of: selectedItem) { newItem in
                                        Task {
                                            // Retrive selected asset in the form of Data
                                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                                withAnimation(.easeIn){
                                                    selectedImageData = data
                                                }
                                            }
                                        }
                                    }
                            } else {
                                Button(action:{
                                    withAnimation(.easeOut){
                                        selectedImageData = nil
                                        selectedItem = nil
                                    }
                                }){
                                    Image(systemName: "x.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color("color-prime"))
                                }
                            }
                        }.frame(height: 40)
                        
                        if let imgData = selectedImageData {
                            let img = UIImage(data: imgData)
                            if let i = img {
                                Image(uiImage: i)
                                    .resizable()
                                    .frame(width: SCREEN_WIDTH-25, height: 250)
                                    .scaledToFill()
                                    .clipped()
                            }
                            
                        }
                    }.padding(.top)
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .center){
                            Button(action: { Task { await CreateClub() } }) {
                                LoadingButton(text: "Create Club", width: 150, status: $state)
                            }.disabled(state == .pending ? false : true)
                        }.frame(width: SCREEN_WIDTH-25)
                            .padding(.top, 50)
                    }
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                .padding(.top)
            }.frame(width: SCREEN_WIDTH-25)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{ dismiss() }) {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Create Club")
                            .font(.title3)
                            .bold()
                    }
                }
                .task {
                    guard let user = session.user, let sports = user.sports else {
                        return
                    }
                    self.userSports = sports
                }
        }
    }
}

#Preview {
    NewClub()
        .environmentObject(SessionStore())
}
