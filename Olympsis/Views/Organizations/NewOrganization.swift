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
    
    @StateObject private var viewModel = NewGroupViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "create_new_club_view")
    
    @MainActor
    func createOrganization() async {
        // generate DTO
        guard let dto = await viewModel.createOrganizationDTO() else {
            return
        }
        
        // grab current location and create club
        let geoCoder = CLGeocoder()
        if let location = session.locationManager.location {
            let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
            do {
                let pk = try await geoCoder.reverseGeocodeLocation(l)
                guard let country = pk.first?.country,
                      let state = pk.first?.administrativeArea,
                      let city = pk.first?.locality else {
                    return
                }
                dto.city = city
                dto.state = state
                dto.country = country
                
                // create new club
                guard let user = session.user,
                    let id = try await session.orgObserver.createOrganization(organization: dto) else {
                    viewModel.state = .failure
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
                            joinedAt: Int64(Date().timeIntervalSince1970)
                        )
                    ],
                    blackList: nil,
                    pinnedPosts: nil,
                    isVerified: false,
                    createdAt: Int(Date().timeIntervalSince1970)
                )
                
                let group = GroupSelection(type: GROUP_TYPE.Organization, club: nil, organization: org, posts: nil)
                session.groups.append(group)
                session.selectedGroup = group

                viewModel.showToast = true
                viewModel.state = .success
                dismiss()
            } catch {
                viewModel.state = .failure
                log.error("Failed to create club: \(error)")
            }
        } else {
            if let hometown = session.user?.hometown {
                let l = CLLocation(latitude: hometown[0], longitude: hometown[1])
                do {
                    let pk = try await geoCoder.reverseGeocodeLocation(l)
                    guard let country = pk.first?.country,
                          let state = pk.first?.administrativeArea,
                          let city = pk.first?.locality else {
                        return
                    }
                    dto.city = city
                    dto.state = state
                    dto.country = country
                    
                    // create new club
                    guard let user = session.user,
                        let id = try await session.orgObserver.createOrganization(organization: dto) else {
                        viewModel.state = .failure
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
                                joinedAt: Int64(Date().timeIntervalSince1970)
                            )
                        ],
                        blackList: nil,
                        pinnedPosts: nil,
                        isVerified: false,
                        createdAt: Int(Date().timeIntervalSince1970)
                    )
                    
                    let group = GroupSelection(type: GROUP_TYPE.Organization, club: nil, organization: org, posts: nil)
                    session.groups.append(group)
                    session.selectedGroup = group

                    viewModel.showToast = true
                    viewModel.state = .success
                    dismiss()
                } catch {
                    viewModel.state = .failure
                    log.error("Failed to create club: \(error)")
                }
            }
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
                                            .foregroundStyle(Color("background"))
                                    }
                                    
                            }
                        }.overlay(alignment: .topTrailing) {
                            Image(systemName: "pencil.circle.fill")
                                .padding(.all, 5)
                                .foregroundStyle(Color("background"))
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
                                    .border(Color("background"), width: 3)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .padding(.all, 5)
                                            .foregroundStyle(Color("background"))
                                    }
                                    .onTapGesture {
                                        viewModel.showLogoMediaPicker.toggle()
                                    }
                            } else {
                                Rectangle()
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 100)
                                    .border(Color("background"), width: 3)
                                    .overlay {
                                        Image(systemName: "person.3.fill")
                                            .foregroundStyle(Color("background"))
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .padding(.all, 5)
                                            .foregroundStyle(Color("background"))
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
                    
                    VStack (alignment: .leading){
                        Text("Organization Name:")
                            .font(.title3)
                            .bold()
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextField("", text: $viewModel.clubName)
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
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextEditor(text: $viewModel.description)
                            .scrollContentBackground(.hidden)
                        .frame(height: 200)
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
                                .foregroundColor(.primary)
                                .opacity(0.1)
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
                    }
                    .padding(.top)
                    .frame(width: SCREEN_WIDTH-25)
                    .fullScreenCover(isPresented: $viewModel.showSportsPicker, content: {
                        MultiSportsPicker(selectedSports: $viewModel.selectedSports)
                    })
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .center){
                            Button(action: { Task { await createOrganization() } }) {
                                LoadingButton(text: "Create", width: 150, status: $viewModel.state)
                            }.disabled(viewModel.state == .pending ? false : true)
                        }.frame(width: SCREEN_WIDTH-25)
                            .padding(.top, 50)
                    }
                    
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                .padding(.top)
            }
            .frame(width: SCREEN_WIDTH-25)
            .navigationTitle("Create Organization")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $viewModel.showMediaWarning, onDismiss: { viewModel.state = .pending }, content: {
                GroupMediaViolation()
            })
        }
    }
}

#Preview {
    NewOrganization()
        .environmentObject(SessionStore())
}
