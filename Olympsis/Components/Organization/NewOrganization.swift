//
//  NewOrganizationView.swift
//  Olympsis
//
//  Created by Joel on 11/13/23.
//

import os
import SwiftUI
import PhotosUI

struct NewOrganization: View {
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
    @State private var country: String = ""
    @State private var states: [String] = [String]()
    
    @StateObject var uploadObserver = UploadObserver()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "create_new_club_view")
    
    func UploadImage() async {
        if let data = selectedImageData {
            // new image
            let imageId = UUID().uuidString
            let _ = await uploadObserver.UploadImage(location: "/olympsis-org-images", fileName: imageId, data: data)
            self.imageURL = "olympsis-org-images/\(imageId).jpeg"
        }
    }
    
    func Validate() -> CREATE_ERROR? {
        if clubName == "" || clubName.count < 3  || clubName.count > 25 {
            return .noName
        }
        return nil
    }
    
    func CreateOrganization() async {
        
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
        
        // grab current location and create organization
        let geoCoder = CLGeocoder()
        guard let location = session.locationManager.location else {
            return
        }
        let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
        do {
            let pk = try await geoCoder.reverseGeocodeLocation(l)
            guard let country = pk.first?.country,
                  let state = pk.first?.administrativeArea else {
                return
            }
            let org = Organization(id: nil, name: clubName, description: description, sport: sport, city: nil, state: state, country: country, imageURL: imageURL, imageGallery: nil, members: nil, pinnedPostId: nil, createdAt: Int64(Date().timeIntervalSinceNow))
            
            // create new organization
            let resp = try await session.orgObserver.createOrganization(organization: org)
            
            let group = GroupSelection(type: "organization", club: nil, organization: resp, posts: nil)
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
                        Text("Organization Name:")
                            .font(.title3)
                            .bold()
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
                        Text("What is this organization about?")
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
                            Text("The sport your organization will focus on")
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
                                Text("Organization Image")
                                    .font(.title3)
                                .bold()
                            }
                            Spacer()
                            if selectedImageData == nil {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
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
                            Button(action: { Task { await CreateOrganization() } }) {
                                LoadingButton(text: "Create", width: 150, status: $state)
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
                        Text("Create Organization")
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
    NewOrganization()
        .environmentObject(SessionStore())
}
