//
//  NoClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import os
import SwiftUI
import AlertToast
import CoreLocation

struct ClubsList: View {
    
    @State private var text: String = ""
    @State private var clubs = [Club]()
    @State private var showCancel: Bool = false
    @State private var showNewClubCover: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var showCompletedApplicationToast:Bool = false
    
    @EnvironmentObject var session: SessionStore
    
    private var geoCoder = CLGeocoder()
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "clubs_list_view")
    
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
                        if clubs.isEmpty {
                            Text("There are no clubs in your area. Broaden your search or...")
                                .font(.caption)
                                .padding(.top, 50)
                            Button(action:{ showNewClubCover.toggle() }){
                                Text("Create One?")
                                    .font(.caption)
                            }
                                
                        } else {
                            if text != ""{
                                ForEach(clubs.filter{$0.name!.lowercased().contains(text.lowercased())}, id: \.id){ c in
                                    SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: session.clubObserver)
                                        .padding(.bottom)
                                }
                            } else {
                                ForEach(clubs, id: \.id){ c in
                                    SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: session.clubObserver)
                                        .padding(.bottom)
                                }
                            }
                        }
                    }
                }
            }.toast(isPresenting: $showCompletedApplicationToast){
                AlertToast(displayMode: .banner(.pop), type: .regular, title: "Application Sent!", style: .style(titleColor: .green, titleFont: .body))
            }
            .refreshable {
                guard let location = session.locationManager.location else {
                    return
                }
                let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
                do {
                    let pk = try await geoCoder.reverseGeocodeLocation(l)
                    guard let country = pk.first?.country,
                          let state = pk.first?.administrativeArea else {
                        return
                    }
                    let resp = await session.clubObserver.getClubs(country: country, state: state)
                    guard let clubs = resp else {
                        return
                    }
                    await MainActor.run {
                        self.clubs = clubs
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
                    let pk = try await geoCoder.reverseGeocodeLocation(l)
                    guard let country = pk.first?.country,
                          let state = pk.first?.administrativeArea else {
                        return
                    }
                    let resp = await session.clubObserver.getClubs(country: country, state: state)
                    guard let clubs = resp else {
                        status = .failure
                        return
                    }
                    await MainActor.run {
                        self.clubs = clubs
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
