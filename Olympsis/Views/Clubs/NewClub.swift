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
    
    @StateObject private var viewModel = NewGroupViewModel()
    
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "create_new_club_view")
    
    @MainActor
    func CreateClub() async {
        // generate DTO
        guard let dto = await viewModel.createClubDTO() else {
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
                    let id = try await session.clubObserver.createClub(club: dto) else {
                    viewModel.state = .failure
                    log.error("Failed to create club")
                    return
                }
                
                let club = Club(
                    id: id, parent: nil,
                    name: dto.name,
                    logo: dto.logo,
                    banner: dto.banner,
                    sports: dto.sports,
                    description: dto.description,
                    city: dto.city,
                    state: dto.state,
                    country: dto.country,
                    visibility: dto.visibility,
                    members: [
                        Member(
                            id: UUID().uuidString, 
                            role: "owner",
                            user: UserSnippet(uuid: user.uuid, username: user.username, imageURL: user.imageURL),
                            joinedAt: Int64(Date().timeIntervalSince1970)
                        )
                    ],
                    pinnedPosts: nil,
                    isVerified: false,
                    createdAt: Int(Date().timeIntervalSince1970)
                )
                
                let group = GroupSelection(type: GROUP_TYPE.Club, club: club, organization: nil, posts: nil)
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
                    guard let id = try await session.clubObserver.createClub(club: dto) else {
                        viewModel.state = .failure
                        log.error("Failed to create club")
                        return
                    }
                    
                    let club = Club(
                        id: id, parent: nil,
                        name: dto.name,
                        logo: dto.logo,
                        banner: dto.banner,
                        sports: dto.sports,
                        description: dto.description,
                        city: dto.city,
                        state: dto.state,
                        country: dto.country,
                        visibility: dto.visibility,
                        pinnedPosts: nil,
                        createdAt: Int(Date().timeIntervalSince1970)
                    )
                    
                    let group = GroupSelection(type: GROUP_TYPE.Club, club: club, organization: nil, posts: nil)
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
                    Text("Club Name:")
                        .font(.title3)
                        .bold()
                    Text("What your club will be known by")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
                    Text("What your club is about?")
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
                        Text("The sport(s) your club will focus on")
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
                        Button(action: { Task { await CreateClub() } }) {
                            LoadingButton(text: "Create", width: 150, status: $viewModel.state)
                        }.disabled(viewModel.state == .pending ? false : true)
                    }
                    .frame(width: SCREEN_WIDTH-25)
                    .padding(.top, 50)
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
            .padding(.top)
        }
        .frame(width: SCREEN_WIDTH-25)
        .navigationTitle("Create Club")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showMediaWarning, onDismiss: { viewModel.state = .pending }, content: {
            GroupMediaViolation()
        })
    }
}

#Preview {
    NewClub()
        .environmentObject(SessionStore())
}
