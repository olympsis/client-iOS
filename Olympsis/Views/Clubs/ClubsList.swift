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

    @State private var text: String = ""
    @State private var numFiltersActive = 0
    @State private var showMenu: Bool = false
    @State private var showEULA: Bool = false
    @State private var hasLoaded: Bool = false
    @State private var showCancel: Bool = false
    @State private var showNewClub: Bool = false
    @State private var status: LOADING_STATE = .pending
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
        return CLLocation(latitude: hometown[0], longitude: hometown[1])
    }
    
    private var currentLocation: CLLocation {
        guard CLLocationManager.locationServicesEnabled(),
            let location = session.locationManager.location else {
            return fallbackLocation
        }
        
        return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    private var tags: [Tag] {
        return session.tags;
    }
    
    private var sports: [Sport] {
        return session.sports;
    }
    
    private var filteredClubs: [Club] {
        if text == "" {
            guard let user = session.user,
                  let userClubs = user.clubs else {
                return session.clubs
            }
            return session.clubs.filter { club in
                !userClubs.contains(where: { club.id == $0 })
            }
        } else {
            guard let user = session.user,
                  let userClubs = user.clubs else {
                return session.clubs
            }
            let newClubs = session.clubs.filter { club in
                !userClubs.contains(where: { club.id == $0 })
            }
            return newClubs.filter{ $0.name.lowercased().contains(text.lowercased()) }
        }
    }
    
    private func handleShowNewClub() {
        guard acceptedEULA else {
            self.showEULA.toggle()
            return
        }
        self.showNewClub.toggle()
    }
    
    @MainActor
    private func fetchClubs() async {
        do {
            status = .loading
            let geoCoder = CLGeocoder()
            let locale = Locale(identifier: "en_US")
            let pk = try await geoCoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale)
            guard let country = pk.first?.country,
                  let state = pk.first?.administrativeArea,
                  let resp = await session.clubObserver.getClubs(country: country, state: stateAbbreviationToFullName[state] ?? state, location: GeoJSON(type: "Point", coordinates: [currentLocation.coordinate.latitude, currentLocation.coordinate.longitude])) else {
                status = .failure
                return
            }
            
            session.clubs = resp
            status = .success
            hasLoaded = true
        } catch {
            log.error("Failed to get clubs. Error: \(error)")
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                status = .pending
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .trailing) {
                        
                        // MARK: - Search
                        HStack {
                            SearchBar(text: $text, onCommit: {
                                showCancel = false
                            }).onTapGesture {
                                    if !showCancel {
                                        showCancel = true
                                    }
                                }
                            .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
                            .padding(.horizontal)
                            .padding(.top)
                            .onChange(of: text) { _, new in
                                if !new.isEmpty {
                                    withAnimation(.easeInOut) {
                                        showCancel = true
                                    }
                                } else {
                                    withAnimation(.easeInOut) {
                                        showCancel = false
                                    }
                                }
                            }
                            
                            if showCancel {
                                Button(action:{
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                    withAnimation(.easeInOut) {
                                        text = ""
                                        showCancel = false
                                    }
                                }){
                                    Text("Cancel")
                                        .foregroundColor(.gray)
                                        .frame(height: 40)
                                        .padding(.top)
                                }.padding(.trailing)
                            }
                        }
                        
                        // MARK: - Actions
                        HStack {
                            Button(action: handleShowNewClub) {
                                Image(systemName: "plus")
                                
                                Text("Create a Club")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            
                            FilterButton(numActive: $numFiltersActive, action: { showMenu.toggle() })
                        }.padding(.trailing)
                    }
                    
                    // MARK: - List View
                    if self.status == .loading {
                        ProgressView()
                            .padding(.top)
                    } else {
                        VStack{
                            if filteredClubs.isEmpty {
                                Text("No clubs found. Change your filters or...")
                                    .font(.caption)
                                    .padding(.top, 50)
                                
                                Button(action: handleShowNewClub){
                                    Text("Create One?")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                            } else {
                                ForEach(text.isEmpty ? filteredClubs : filteredClubs.filter{ $0.name.lowercased().contains(text.lowercased()) }, id: \.id){ club in
                                    ClubListItem(club: club, showToast: $showCompletedApplicationToast)
                                        .clipShape(Rectangle())
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    await fetchClubs()
                }
            }
            .task {
                guard !hasLoaded else {
                    return
                }
                await fetchClubs()
            }
            .sheet(isPresented: $showMenu, onDismiss: {                
                withAnimation(.easeInOut) {
                    numFiltersActive = manager.selectedSports.count + manager.selectedTags.count
                }
            }, content: {
                FilterView(manager: manager)
                    .environment(session)
            })
            .sheet(isPresented: $showEULA, content: {
                EndUserLicenseAgreement()
            })
            .fullScreenCover(isPresented: $showNewClub) {
                NewGroup()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Clubs")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .task {
                manager.tags = session.tags
                manager.sports = session.sports
                #if targetEnvironment(simulator)
                manager.tags = TAGS_TEMP
                manager.sports = SPORTS_TEMP
                #endif
            }
        }
    }
}

#Preview {
    ClubsList()
        .environment(SessionStore())
}
