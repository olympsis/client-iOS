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
    
    @State private var showLocationPicker = false
    @StateObject private var viewModel = GroupEditorViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "create_new_club_view")
    
    @MainActor
    func createOrganization() async {
        // generate DTO
        guard let dto = await viewModel.createOrganizationDTO() else {
            return
        }
        
        do {
            // create new organization
            guard let user = session.user,
                let id = try await session.orgObserver.createOrganization(organization: dto) else {
                viewModel.status = .failure
                log.error("Failed to create club")
                return
            }
            
            let org = Organization(
                id: id,
                name: dto.name,
                description: dto.description,
                sports: dto.sports,
                city: dto.city,
                state: dto.state,
                country: dto.country,
                logo: dto.logo,
                banner: dto.banner,
                members: [
                    Member(
                        id: UUID().uuidString,
                        role: "owner",
                        user: UserSnippet(uuid: user.uuid, username: user.username, imageURL: user.imageURL),
                        joinedAt: Date()
                    )
                ],
                blackList: nil,
                pinnedPosts: nil,
                isVerified: false,
                createdAt: Date()
            )
            
            let group = GroupSelection(type: GROUP_TYPE.Organization, club: nil, organization: org, posts: nil)
            session.groups.append(group)
            session.selectedGroup = group

            viewModel.showToast = true
            viewModel.status = .success
            dismiss()
        } catch {
            viewModel.status = .failure
            log.error("Failed to create club: \(error)")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false){
                VStack (alignment: .leading){
                    
                    ZStack(alignment: .top) {
                        Group {
                            if let img = viewModel.bannerPhoto {
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(height: 200)
                            } else {
                                Rectangle()
                                    .frame(height: 200)
                                    .foregroundStyle(.gray)
                                    .overlay {
                                        Image(systemName: "photo.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(Color(Color.Background.secondary))
                                    }
                                    
                            }
                        }.overlay(alignment: .topTrailing) {
                            Image(systemName: "pencil.circle.fill")
                                .padding(.all, 5)
                                .foregroundStyle(Color(Color.Background.secondary))
                        }
                        .fullScreenCover(isPresented: $viewModel.showBannerMediaPicker) {
                            MediaPicker(pickerType: .other) { images in
                                if let img = images.first {
                                    DispatchQueue.main.async {
                                        viewModel.bannerPhoto = img
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            viewModel.showBannerMediaPicker.toggle()
                        }
                        
                        VStack {
                            Spacer()
                            if let img = viewModel.logoPhoto {
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .border(Color(Color.Background.secondary), width: 3)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .padding(.all, 5)
                                            .foregroundStyle(Color(Color.Background.secondary))
                                    }
                                    .onTapGesture {
                                        viewModel.showLogoMediaPicker.toggle()
                                    }
                            } else {
                                Rectangle()
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 100)
                                    .border(Color(Color.Background.secondary), width: 3)
                                    .overlay {
                                        Image(systemName: "person.3.fill")
                                            .foregroundStyle(Color(Color.Background.secondary))
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .padding(.all, 5)
                                            .foregroundStyle(Color(Color.Background.secondary))
                                    }
                                    .onTapGesture {
                                        viewModel.showLogoMediaPicker.toggle()
                                    }
                            }
                        }.fullScreenCover(isPresented: $viewModel.showLogoMediaPicker) {
                            MediaPicker(pickerType: .newEvent) { images in
                                if let img = images.first {
                                    DispatchQueue.main.async {
                                        viewModel.logoPhoto = img
                                    }
                                }
                            }
                        }
                    }.frame(height: 250)
                    
                    // MARK: - Name
                    Group {
                        VStack (alignment: .leading){
                            Text("Organization Name:")
                                .font(.title3)
                                .bold()
                        }
                        VStack(alignment: .leading) {
                            TextField("", text: $viewModel.clubName)
                                .padding(.leading)
                                .frame(height: 40)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(Color.Background.secondary))
                                }
                            
                            Text("*required")
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    // MARK: - Description
                    Group {
                        VStack(alignment: .leading){
                            Text("Description:")
                                .font(.title3)
                                .bold()
                            .padding(.top)
                            Text("What is this organization about?")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            TextEditor(text: $viewModel.description)
                                .scrollContentBackground(.hidden)
                                .frame(height: 200)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(Color.Background.secondary))
                                }
                            Text("*required")
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    // MARK: - Sports picker
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Sport")
                                .font(.title3)
                                .bold()
                            Text("The sport(s) your organization will focus on")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(Color.Background.secondary))
                                .frame(height: 40)
                            Button(action: {
                                viewModel.showSportsPicker.toggle()
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
                            }
                        }
                        
                        Text("*required")
                            .foregroundStyle(.gray)
                    }
                    .padding(.top)
                    .frame(width: SCREEN_WIDTH-25)
                    .fullScreenCover(isPresented: $viewModel.showSportsPicker, content: {
                        MultiSportsPicker(selectedSports: $viewModel.selectedSports)
                    })
                    
                    // MARK: - Hometown picker
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Hometown")
                            HStack(alignment: .top) {
                                Text("Where does this club call home?")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }.foregroundStyle(.gray)
                        }
                        Button(action: { self.showLocationPicker.toggle() }) {
                            if (viewModel.latitude == 0 && viewModel.longitude == 0 || viewModel.city == "") {
                                Text("N/A")
                            } else {
                                Text("\(viewModel.city), \(viewModel.state) (\(viewModel.country))")
                            }
                        }.frame(maxWidth: .infinity, idealHeight: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundColor(Color(Color.Background.secondary))
                        }
                        
                        Text("*required")
                            .foregroundStyle(.gray)
                    }
                    .padding(.top)
                    .fullScreenCover(isPresented: $showLocationPicker, content: {
                        ProfileHometownPicker(city: $viewModel.city, state: $viewModel.state, country: $viewModel.country, latitude: $viewModel.latitude, longitude: $viewModel.longitude)
                    })
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .center){
                            Button(action: { Task { await createOrganization() } }) {
                                LoadingButton(text: "Create", width: 150, status: $viewModel.status)
                            }.disabled(viewModel.status == .pending ? false : true)
                        }.frame(width: SCREEN_WIDTH-25)
                            .padding(.top, 50)
                    }
                    
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                .padding(.top)
            }
            .frame(width: SCREEN_WIDTH-25)
            .background(Color.Background.primary)
            .navigationTitle("Create Organization")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $viewModel.showMediaWarning, onDismiss: { viewModel.status = .pending }, content: {
                GroupMediaViolation()
            })
        }
    }
}

#Preview {
    NewOrganization()
        .environment(SessionStore())
}
