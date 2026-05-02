//
//  NoClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import os
import MapKit
import SwiftUI
import CoreLocation

struct ClubsList: View {

    @State private var searchText: String = ""
    
    @State private var numFiltersActive = 0
    @State private var showMenu: Bool = false
    @State private var showEULA: Bool = false
    @State private var hasLoaded: Bool = false
    @State private var showCancel: Bool = false
    @State private var showNewClub: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var showRequestLocation: Bool = false
    @State private var showCompletedApplicationToast:Bool = false
    
    @State private var manager = SearchManager()
    
    @Environment(SessionStore.self) private var session
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "clubs_list_view")
    
    private var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
    private var fallbackLocation: CLLocation {
        guard let user = session.user, let hometown = user.hometown else {
            return CLLocation(latitude: 37.334886, longitude: -122.008988)
        }
        return CLLocation(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0])
    }
    
    private var currentLocation: CLLocation {
        guard LocationManager.shared.isLocationAuthorized,
            let location = LocationManager.shared.location else {
            return fallbackLocation
        }
        
        return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    var hasLocation: Bool {
        return LocationManager.shared.isAuthorized
    }
    
    private var tags: [Tag] {
        return session.tags;
    }
    
    private var sports: [Sport] {
        return session.sports;
    }
    
    private var filteredClubs: [Club] {
        guard !searchText.isEmpty else {
            guard let user = session.user,
                  let userClubs = user.clubs else {
                return session.clubs
                    // Check if any selected tag is in the club's tags
                    .filter { club in
                        manager.selectedTags.isEmpty ||
                        manager.selectedTags.contains { selectedTag in club.tags.contains(selectedTag) }
                    }
                    // Check if any selected sport is in the club's sports
                    .filter { club in
                        manager.selectedSports.isEmpty ||
                        manager.selectedSports.contains { selectedSport in club.sports.contains(selectedSport) }
                    }
            }
            return session.clubs
                .filter { club in !userClubs.contains(where: { club.id == $0 }) }
                // Check if any selected tag is in the club's tags
                .filter { club in
                    manager.selectedTags.isEmpty ||
                    manager.selectedTags.contains { selectedTag in club.tags.contains(selectedTag) }
                }
                // Check if any selected sport is in the club's sports
                .filter { club in
                    manager.selectedSports.isEmpty ||
                    manager.selectedSports.contains { selectedSport in club.sports.contains(selectedSport) }
                }
        }
        
        guard let user = session.user,
              let userClubs = user.clubs else {
            return session.clubs
                // Check if any selected tag is in the club's tags
                .filter { club in
                    manager.selectedTags.isEmpty ||
                    manager.selectedTags.contains { selectedTag in club.tags.contains(selectedTag) }
                }
                // Check if any selected sport is in the club's sports
                .filter { club in
                    manager.selectedSports.isEmpty ||
                    manager.selectedSports.contains { selectedSport in club.sports.contains(selectedSport) }
                }
                .filter { $0.name.localizedLowercase.contains(searchText.localizedLowercase) }
        }
        return session.clubs
            .filter { club in !userClubs.contains(where: { club.id == $0 }) }
            // Check if any selected tag is in the club's tags
            .filter { club in
                manager.selectedTags.isEmpty ||
                manager.selectedTags.contains { selectedTag in club.tags.contains(selectedTag) }
            }
            // Check if any selected sport is in the club's sports
            .filter { club in
                manager.selectedSports.isEmpty ||
                manager.selectedSports.contains { selectedSport in club.sports.contains(selectedSport) }
            }
            .filter { $0.name.localizedLowercase.contains(searchText.localizedLowercase) }
    }
    
    private func handleShowNewClub() {
        guard acceptedEULA else {
            self.showEULA.toggle()
            return
        }
        self.showNewClub.toggle()
    }
    
    @MainActor
    private func fetchClubs() {
        guard status != .loading else { return }
        Task { @MainActor in
            do {
                status = .loading
                let geoCoder = CLGeocoder()
                let locale = Locale(identifier: "en_US")
                let pk = try await geoCoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale)
                
                var tags: String? = nil
                var sports: String? = nil
                
                if (!manager.tags.isEmpty) {
                    tags = manager.getTagsString()
                }
                
                if (!manager.sports.isEmpty) {
                    sports = manager.getSportsString()
                }
                
                guard let country = pk.first?.country,
                      let state = pk.first?.administrativeArea,
                      let resp = await session.clubObserver.getClubs(
                        country: country,
                        state: stateAbbreviationToFullName[state] ?? state,
                        location: GeoJSON(
                            type: "Point",
                            coordinates: [
                                currentLocation.coordinate.latitude,
                                currentLocation.coordinate.longitude
                            ]),
                        radius: manager.radius,
                        tags: tags,
                        sports: sports
                      ) else {
                    status = .failure
                    return
                }
                
                resp.forEach { session.clubs.insert($0) }
                
                status = .success
                hasLoaded = true
            } catch {
                log.error("Failed to get clubs. Error: \(error)")
                status = .failure
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .trailing) {
//                
//                // MARK: - Search
//                HStack {
//                    SearchBar(text: $searchText, onCommit: {
//                        showCancel = false
//                    }).onTapGesture {
//                            if !showCancel {
//                                showCancel = true
//                            }
//                        }
//                    .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
//                    .padding(.horizontal)
//                    .padding(.top)
//                    .onChange(of: searchText) { _, new in
//                        if !new.isEmpty {
//                            withAnimation(.easeInOut) {
//                                showCancel = true
//                            }
//                        } else {
//                            withAnimation(.easeInOut) {
//                                showCancel = false
//                            }
//                        }
//                    }
//                    
//                    if showCancel {
//                        Button(action:{
//                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
//                            withAnimation(.easeInOut) {
//                                searchText = ""
//                                showCancel = false
//                            }
//                        }){
//                            Text(String(localized: "cancel", table: "General"))
//                                .foregroundColor(.gray)
//                                .frame(height: 40)
//                                .padding(.top)
//                        }.padding(.trailing)
//                    }
//                }
                
                // MARK: - Actions
                HStack {
                    Spacer()
                    
                    Button(action: handleShowNewClub) {
                        HStack {
                            Image(systemName: "plus")
                            Text(String(localized: "create-club", table: "Groups"))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }
                    
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    FilterButton(numActive: $numFiltersActive, action: { showMenu.toggle() })
                }.padding(.trailing)
            }
            
            // MARK: - List View
            switch status {
            case .pending, .success:
                VStack{
                    if filteredClubs.isEmpty {
                        
                        Spacer(minLength: 50)
                        
                        Image("illustrations/search")
                            .resizable()
                            .padding(.top)
                            .frame(width: 150, height: 110)
                        
                        Text(String(localized: "no-clubs-title", table: "General"))
                            .font(.body)
                            .padding(.top)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Text(String(localized: "no-clubs-sub-title", table: "General"))
                            .font(.callout)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .multilineTextAlignment(.leading)
                    } else {
                        ForEach(searchText.isEmpty ? filteredClubs : filteredClubs.filter{ $0.name.lowercased().contains(searchText.lowercased()) }, id: \.id){ club in
                            ClubListItem(club: club, showToast: $showCompletedApplicationToast)
                                .clipShape(Rectangle())
                                .padding(.horizontal, 10)
                        }
                    }
                }
            case .loading:
                ProgressView()
                    .padding(.top)
            case .failure:
                VStack {
                    Image("illustrations/error")
                        .resizable()
                        .frame(width: 170, height: 150)
                    Text(String(localized: "generic-error-fun-text", table: "General"))
                        .padding(.top)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    Text(String(localized: "generic-error-fetching-clubs", table: "General"))
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding(.top, 50)
            }
        }
        .refreshable {
            fetchClubs()
        }
        .sheet(isPresented: $showMenu, onDismiss: {
            withAnimation(.easeInOut) {
                numFiltersActive = manager.selectedSports.count + manager.selectedTags.count
                
                fetchClubs()
            }
        }, content: {
            FilterView()
                .environment(manager)
                .environment(session)
                .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showEULA, content: {
            EndUserLicenseAgreement()
        })
        .fullScreenCover(isPresented: $showNewClub) {
            NewGroup()
        }
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Clubs")
                        .fixedSize()
                        .fontWeight(.bold)
                        .font(.custom("Archivo-Black", size: 30, relativeTo: .title))
                }.sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Clubs")
                        .fontWeight(.bold)
                        .font(.custom("Archivo-Black", size: 30, relativeTo: .title))
                }
            }
            
            if !hasLocation {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { self.showRequestLocation.toggle() }) {
                        Image(systemName: "location.slash")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showRequestLocation, onDismiss: {
            Task {
                await session.updateNotifications()
            }
        }) {
            LocationRequestView()
        }
        .task {
            // Grab sports and tags from session
            manager.tags = session.tags
            manager.sports = session.sports
            
            // Add user's sports on the filter by default
            if let user = session.user {
                if let sports = user.sports {
                    manager.selectedSports = sports
                    
                    withAnimation(.easeInOut) {
                        numFiltersActive = manager.selectedSports.count + manager.selectedTags.count
                    }
                }
            }
            
            // For development
            #if targetEnvironment(simulator)
            manager.tags = TAGS_TEMP
            manager.sports = SPORTS_TEMP
            #endif
            
            // Fetch clubs
            if !hasLoaded {
                fetchClubs()
            }
        }.searchable(text: $searchText, placement: .toolbar)
    }
}

#Preview {
    NavigationStack {
        ClubsList()
            .environment(SessionStore())
    }
}
