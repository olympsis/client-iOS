//
//  NoClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import os
import SwiftUI
import CoreLocation

struct ClubsList: View {

    @State private var text: String = ""
    @State private var showMenu: Bool = false
    @State private var showEULA: Bool = false
    @State private var hasLoaded: Bool = false
    @State private var showCancel: Bool = false
    @State private var showNewClub: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var customCoordinates: [Double] = []
    @State private var showCompletedApplicationToast:Bool = false
    
    @Environment(SessionStore.self) private var session
    
    private var geoCoder = CLGeocoder()
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
    
    @MainActor
    private func fetchClubs(_ customLocation: [Double]) async {
        guard customLocation.isEmpty else {
            // Fetch clubs using location recieved
            let l = CLLocation(latitude: customLocation[0], longitude: customLocation[1])
            do {
                status = .loading
                let locale = Locale(identifier: "en_US")
                let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                guard let country = pk.first?.country,
                      let state = pk.first?.administrativeArea,
                      let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                    status = .failure
                    session.clubs = []
                    return
                }
                
                session.clubs = resp
                status = .success
                hasLoaded = true
            } catch {
                log.error("\(error)")
                status = .failure
                return
            }
            return
        }
        
        // If we have location access and have a location
        guard session.locationManager.isAuthorized,
              let location = session.locationManager.location else {
            do { // Use fallback location fetch clubs
                status = .loading
                let locale = Locale(identifier: "en_US")
                let l = CLLocation(latitude: fallbackLocation.coordinate.latitude, longitude: fallbackLocation.coordinate.longitude)
                let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                guard let country = pk.first?.country,
                      let state = pk.first?.administrativeArea,
                      let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                    status = .failure
                    return
                }
                
                session.clubs = resp
                status = .success
                hasLoaded = true
            } catch {
                log.error("\(error)")
                status = .failure
            }
            return
        }
        
        // Fetch clubs using location recieved
        let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
        do {
            status = .loading
            let locale = Locale(identifier: "en_US")
            let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
            guard let country = pk.first?.country,
                  let state = pk.first?.administrativeArea,
                  let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                status = .failure
                return
            }
            
            session.clubs = resp
            status = .success
            hasLoaded = true
        } catch {
            log.error("\(error)")
            status = .failure
            return
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    if showCancel {
                        Button(action:{
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            showCancel = false
                        }){
                            Text("Cancel")
                                .foregroundColor(.gray)
                                .frame(height: 40)
                                .padding(.top)
                        }.padding(.trailing)
                    }
                }
                ScrollView(.vertical, showsIndicators: false){
                    if self.status == .loading {
                        ProgressView()
                            .padding(.top)
                    } else {
                        VStack{
                            if filteredClubs.isEmpty {
                                Text("No clubs found. Broaden your search or...")
                                    .font(.caption)
                                    .padding(.top, 50)
                                Button(action:{
                                    guard acceptedEULA else {
                                        self.showEULA.toggle()
                                        return
                                    }
                                    self.showNewClub.toggle()
                                }){
                                    Text("Create One?")
                                        .font(.caption)
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
                    await fetchClubs(customCoordinates)
                }
            }
            .background(Color.Background.primary)
            .task {
                guard !hasLoaded else {
                    return
                }
                await fetchClubs(customCoordinates)
            }
            .onChange(of: customCoordinates, { _, newValue in
                Task {
                    await fetchClubs(newValue)
                }
            })
            .sheet(isPresented: $showEULA, content: {
                EndUserLicenseAgreement()
            })
            .fullScreenCover(isPresented: $showNewClub) {
                NewGroup()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Groups")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NoClubMenu(location: $customCoordinates)) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Color.foreground)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

#Preview {
    ClubsList()
        .environment(SessionStore())
}
