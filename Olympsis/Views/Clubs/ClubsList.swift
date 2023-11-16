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
    @State private var showCancel: Bool = false
    @State private var showNewClubCover: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var showCompletedApplicationToast:Bool = false
    
    @EnvironmentObject var session: SessionStore
    
    private var geoCoder = CLGeocoder()
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "clubs_list_view")
    
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
            return newClubs.filter{ $0.name!.lowercased().contains(text.lowercased()) }
        }
    }
    
    var body: some View {
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
                .padding(.leading, 5)
                .padding(.trailing, 5)
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
                            Button(action:{ showNewClubCover.toggle() }){
                                Text("Create One?")
                                    .font(.caption)
                            }
                        } else {
                            ForEach(filteredClubs, id: \.id){ c in
                                SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: session.clubObserver)
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
        .task {
            if clubs.isEmpty {
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
            }
        }
        .fullScreenCover(isPresented: $showNewClubCover) {
            CreateNewClub()
        }
    }
}

struct NoClubView_Previews: PreviewProvider {
    static var previews: some View {
        ClubsList().environmentObject(SessionStore())
    }
}
