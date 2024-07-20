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
    @State var clubs = [Club]()
    @State private var showMenu = false
    @State private var showEULA: Bool = false
    @State private var showCancel: Bool = false
    @State private var showNewClub: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var showCompletedApplicationToast:Bool = false
    
    @EnvironmentObject var session: SessionStore
    
    private var geoCoder = CLGeocoder()
    private var log = Logger(subsystem: "com.olympsis.client", category: "clubs_list_view")
    
    var acceptedEULA: Bool {
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
                    return clubs
            }
            return clubs.filter { club in
                !userClubs.contains(where: { club.id == $0 })
            }
        } else {
            guard let user = session.user,
                  let userClubs = user.clubs else {
                return clubs
            }
            let newClubs = clubs.filter { club in
                !userClubs.contains(where: { club.id == $0 })
            }
            return newClubs.filter{ $0.name.lowercased().contains(text.lowercased()) }
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
                    if self.status == .pending {
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
                                ForEach(text.isEmpty ? filteredClubs : filteredClubs.filter{ $0.name.contains(text) }, id: \.id){ club in
                                    ClubListItem(club: club, showToast: $showCompletedApplicationToast)
                                        .clipShape(Rectangle())
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    guard let location = session.locationManager.location else {
                        return
                    }
                    
                    let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    
                    do {
                        let locale = Locale(identifier: "en_US")
                        let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                        guard let country = pk.first?.country,
                              let state = pk.first?.administrativeArea,
                              let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                            return
                        }
                        await MainActor.run {
                            self.clubs = resp
                        }
                    } catch {
                        log.error("\(error)")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Groups")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NoClubMenu()) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Color.foreground)
                            .imageScale(.large)
                    }
                }
            }
            .task {
                if clubs.isEmpty {
                    
                    // If we are not authorized to have the user's location we rely on the fallback location
                    if (!session.locationManager.isAuthorized) {
                        do {
                            let locale = Locale(identifier: "en_US")
                            let l = CLLocation(latitude: fallbackLocation.coordinate.latitude, longitude: fallbackLocation.coordinate.longitude)
                            let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                            guard let country = pk.first?.country,
                                  let state = pk.first?.administrativeArea,
                                  let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                                status = .failure
                                return
                            }
                            await MainActor.run {
                                self.clubs = resp
                                status = .success
                            }
                        } catch {
                            log.error("\(error)")
                            status = .failure
                            return
                        }
                        
                        status = .success
                        return
                        
                    } else {
                        
                        // Check and see if we have the user's actual location
                        // If we don't then we use the location fall back
                        guard let location = session.locationManager.location else {
                            do {
                                let locale = Locale(identifier: "en_US")
                                let l = CLLocation(latitude: fallbackLocation.coordinate.latitude, longitude: fallbackLocation.coordinate.longitude)
                                let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                                guard let country = pk.first?.country,
                                      let state = pk.first?.administrativeArea,
                                      let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                                    status = .failure
                                    return
                                }
                                await MainActor.run {
                                    self.clubs = resp
                                    status = .success
                                }
                            } catch {
                                log.error("\(error)")
                            }
                            status = .success
                            return
                        }
                        
                        // We do have the user's location, then continue with query
                        let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        do {
                            let locale = Locale(identifier: "en_US")
                            let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                            guard let country = pk.first?.country,
                                  let state = pk.first?.administrativeArea,
                                  let resp = await session.clubObserver.getClubs(country: country, state: state) else {
                                status = .failure
                                return
                            }
                            await MainActor.run {
                                self.clubs = resp
                                status = .success
                                return
                            }
                        } catch {
                            log.error("\(error)")
                            status = .failure
                            return
                        }
                    }
                }
            }
            .sheet(isPresented: $showEULA, content: {
                EndUserLicenseAgreement()
            })
            .fullScreenCover(isPresented: $showNewClub) {
                NewGroup()
            }
        }
    }
}

#Preview {
    ClubsList()
        .environmentObject(SessionStore())
}
