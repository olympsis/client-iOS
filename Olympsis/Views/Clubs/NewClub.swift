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
    
    enum Field {
        case title
        case description
    }
    
    var hideTopBar: Bool = false
    
    @FocusState private var focus: Field?
    @State private var showLocationPicker = false
    @State private var viewModel = NewGroupManager()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var locationText: String {
        guard viewModel.selectedCountry != nil,
              let state = viewModel.selectedAdminArea,
              let city = viewModel.selectedSubAdminArea else {
            return "N/A"
        }
        return "\(city.name), \(state.name)"
    }
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "new_club_view")
    
    @MainActor
    func CreateClub() async {
        // generate DTO
        guard let dto = await viewModel.createClubDTO() else {
            log.error("Failed to create club dto")
            return
        }
        
        do {
            // create new club
            guard let user = session.user,
                let id = try await session.clubObserver.createClub(club: dto) else {
                viewModel.status = .failure
                log.error("Failed to create club")
                return
            }
            
            guard let name = dto.name,
                  let sports = dto.sports,
                  let city = dto.city,
                  let state = dto.state,
                  let country = dto.country,
                  let location = dto.location,
                  let visibility = dto.visibility else {
                log.error("Failed to validate DTO data before creating club locally")
                return
            }
            
            let club = Club(
                id: id, parent: nil,
                name: name,
                logo: dto.logo,
                banner: dto.banner,
                sports: sports,
                description: dto.description,
                city: city,
                state: state,
                country: country,
                location: location,
                visibility: visibility,
                members: [
                    Member(
                        id: UUID().uuidString,
                        role: "owner",
                        user: UserSnippet(userID: user.userID, username: user.username, imageURL: user.imageURL),
                        joinedAt: Date()
                    )
                ],
                pinnedPosts: [],
                isVerified: false,
                createdAt: Date()
            )
            
            let group = GroupSelection(type: GROUP_TYPE.Club, club: club, organization: nil, posts: nil)
            session.groupsManager.add(group)
            session.groupsManager.select(group)

            viewModel.showToast = true
            viewModel.status = .success
            dismiss()
        } catch {
            viewModel.status = .failure
            log.error("Failed to create club: \(error)")
        }
    }
    
    var body: some View {
        VStack {
            if !hideTopBar {
                HStack {
                    Button(action: { dismiss() }) {
                        Text(String(localized: "cancel", table: "General"))
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                }.padding(.horizontal)
            }
            
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
                                    .foregroundStyle(Color.Background.secondary)
                                    .overlay {
                                        Image(systemName: "photo.fill")
                                            .imageScale(.large)
                                    }
                                    .overlay {
                                        Rectangle()
                                            .stroke(Color.primary.opacity(0.15))
                                    }
                                
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "pencil.circle.fill")
                                .padding(.all, 10)
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
                                    }
                                    .onTapGesture {
                                        viewModel.showLogoMediaPicker.toggle()
                                    }
                            } else {
                                Rectangle()
                                    .opacity(0.9)
                                    .foregroundStyle(Color.Background.secondary)
                                    .frame(width: 100, height: 100)
                                    .border(Color.primary, width: 2)
                                    .overlay {
                                        Image(systemName: "person.3.fill")
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .padding(.all, 5)
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
                            HStack(alignment: .top) {
                                Text("\(String(localized: "new-club-name-title", table: "Groups")):")
                                    .font(.title3)
                                    .bold()
                                
                                Text("*\(String(localized: "required-text", table: "General"))")
                                    .font(.caption)
                                    .foregroundStyle(Color.Brand.tertiary)
                            }
                            Text(String(localized: "new-club-name-sub-title", table: "Groups"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }.padding(.top)
                        
                        VStack(alignment: .leading) {
                            TextField("", text: $viewModel.clubName)
                                .padding(.leading)
                                .font(.title2)
                                .modifier(InputFieldModifier())
                                .focused($focus, equals: .title)
                            
                        }
                    }.padding(.horizontal, 10)
                    
                    // MARK: - Description
                    Group {
                        VStack(alignment: .leading){
                            HStack(alignment: .top) {
                                Text("\(String(localized: "new-club-description-title", table: "Groups")):")
                                    .font(.title3)
                                    .bold()
                                
                                Text("*\(String(localized: "required-text", table: "General"))")
                                    .font(.caption)
                                    .foregroundStyle(Color.Brand.tertiary)
                            }.padding(.top)
                            
                            Text(String(localized: "new-club-description-sub-title", table: "Groups"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        TextEditor(text: $viewModel.description)
                            .scrollContentBackground(.hidden)
                            .frame(height: 200)
                            .padding(.all, 10)
                            .focused($focus, equals: .description)
                            .modifier(BackgroundPillModifier())
                    }.padding(.horizontal, 10)
                    
                    
                    // MARK: - Sports picker
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            HStack(alignment: .top) {
                                Text(String(localized: "new-club-sport-title", table: "Groups"))
                                    .font(.title3)
                                    .bold()
                                
                                Text("*\(String(localized: "required-text", table: "General"))")
                                    .font(.caption)
                                    .foregroundStyle(Color.Brand.tertiary)
                            }
                            
                            Text(String(localized: "new-club-sport-sub-title", table: "Groups"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Button(action: {
                                focus = nil
                                viewModel.showSportsPicker.toggle()
                            }) {
                                if !viewModel.selectedSports.isEmpty {
                                    ScrollView(.horizontal) {
                                        HStack(alignment: .center) {
                                            ForEach(Array(viewModel.selectedSports), id: \.self) { sport in
                                                Text(sport.capitalized)
                                                    .padding(.vertical, 3)
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 10)
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 5)
                                                            .foregroundStyle(Color.Brand.primary)
                                                    }
                                            }
                                        }
                                    }
                                    .frame(height: 40)
                                    .scrollIndicators(.never)
                                    .contentMargins(10, for: .scrollContent)
                                } else {
                                    HStack {
                                        Spacer()
                                        Text("N/A")
                                        Spacer()
                                    }.frame(height: 40)
                                }
                            }
                            .frame(maxWidth: .infinity, idealHeight: 40)
                            .modifier(BackgroundPillModifier())
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top)
                    .sheet(isPresented: $viewModel.showSportsPicker, content: {
                        MultiSportsPicker(sports: session.sports, selectedSports: $viewModel.selectedSports)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    })
                    
                    // MARK: - Hometown picker
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Text(String(localized: "new-club-location-title", table: "Groups"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("*\(String(localized: "required-text", table: "General"))")
                                    .font(.caption)
                                    .foregroundStyle(Color.Brand.tertiary)
                            }
                            HStack(alignment: .top) {
                                Text(String(localized: "new-club-location-sub-title", table: "Groups"))
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }.foregroundStyle(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Button(action: {
                                focus = nil
                                self.showLocationPicker.toggle()
                            }) {
                                Text(locationText)
                            }
                            .frame(maxWidth: .infinity, idealHeight: 40)
                            .modifier(BackgroundPillModifier())
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal, 10)
                    
                    VStack(alignment: .center){
                        Button(action: { Task { await CreateClub() } }) {
                            LoadingButton(text: String(localized: "create-text", table: "General"), width: 150, status: $viewModel.status)
                        }.disabled(viewModel.status == .pending ? false : true)
                    }
                    .padding(.horizontal, 50)
                    .padding(.top, 50)
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }.padding(.top)
            }
            .sheet(isPresented: $showLocationPicker, content: {
                LocalesPicker(selectedCountry: $viewModel.selectedCountry, selectedAdministrativeArea: $viewModel.selectedAdminArea, selectedSubAdministrativeArea: $viewModel.selectedSubAdminArea)
                    .presentationDetents([.height(300)])
            })
            .fullScreenCover(isPresented: $viewModel.showMediaWarning, onDismiss: { viewModel.status = .pending }, content: {
                GroupMediaViolation()
            })
        }
    }
}

#Preview {
    NewClub()
        .environment(SessionStore())
}
