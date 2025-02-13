//
//  GroupEditor.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/1/24.
//

import SwiftUI
import Kingfisher

struct GroupEditor: View {
    
    @StateObject private var viewModel = GroupEditorViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .top) {
                    Group {
                        if let img = viewModel.bannerPhoto {
                            Image(uiImage: img)
                                .resizable()
                                .frame(height: 200)
                                .onTapGesture {
                                    viewModel.showBannerMediaPicker.toggle()
                                }
                        } else if viewModel.bannerURL != "",
                                    let url = generateImageURL(viewModel.bannerURL) {
                            KFImage(url)
                                .placeholder({
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            ProgressView()
                                        }
                                })
                                .resizable()
                                .frame(height: 200)
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "pencil.circle.fill")
                                        .padding(.all, 5)
                                        .foregroundStyle(Color(Color.Background.secondary))
                                }
                                .onTapGesture {
                                    viewModel.showBannerMediaPicker.toggle()
                                }
                        } else {
                            Rectangle()
                                .frame(height: 200)
                                .foregroundStyle(.gray)
                                .overlay {
                                    Image(systemName: "photo.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(Color(Color.Background.secondary))
                                }
                                .onTapGesture {
                                    viewModel.showBannerMediaPicker.toggle()
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
                        } else if viewModel.logoURL != "",
                                  let url = generateImageURL(viewModel.logoURL) {
                            KFImage(url)
                                .placeholder({
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            ProgressView()
                                        }
                                })
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
                
                // MARK: - Organization Home
                VStack (alignment: .leading){
                    Text("Organization Name:")
                        .font(.title3)
                        .bold()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(Color.Background.secondary))
                    TextField("", text: $viewModel.clubName)
                        .padding(.leading)
                }.frame(height: 40)
                
                // MARK: - Organization Description
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
                        .foregroundColor(Color(Color.Background.secondary))
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
                }
                .padding(.top)
                .frame(width: SCREEN_WIDTH-25)
                .fullScreenCover(isPresented: $viewModel.showSportsPicker, content: {
                    MultiSportsPicker(selectedSports: $viewModel.selectedSports)
                })
                
                VStack(alignment: .leading){
                    VStack(alignment: .center){
                        Button(action: {
                            Task {
                                guard let selectedGroup = session.selectedGroup else {
                                    return
                                }
                                switch selectedGroup.type {
                                case .Club:
                                    guard let club = selectedGroup.club,
                                          await viewModel.updateClub(club) else {
                                        return
                                    }
                                    dismiss()
                                case .Organization:
                                    guard let org = selectedGroup.organization,
                                          await viewModel.updateOrganization(org) else {
                                        return
                                    }
                                    dismiss()
                                }
                            }
                        }) {
                            LoadingButton(text: "Update", width: 150, status: $viewModel.status)
                        }.disabled(viewModel.status == .pending ? false : true)
                    }.frame(width: SCREEN_WIDTH-25)
                        .padding(.top, 50)
                }
            }.padding(.horizontal)
        }
        .navigationTitle("Edit Group")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let selectedGroup = session.selectedGroup else {
                return
            }
            switch selectedGroup.type {
            case .Club:
                guard let club = selectedGroup.club else {
                    return
                }
                viewModel.loadClub(club)
            case .Organization:
                guard let org = selectedGroup.organization else {
                    return
                }
                viewModel.loadOrganization(org)
            }
        }
    }
}

#Preview {
    let session = SessionStore()
    session.selectedGroup = GroupSelection(type: .Club, club: CLUBS[1])
    return NavigationStack {
        GroupEditor()
            .environment(session)
    }
}
