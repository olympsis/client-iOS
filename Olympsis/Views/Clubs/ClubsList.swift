//
//  NoClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI
import AlertToast
import CoreLocation

struct ClubsList: View {
    
    @State private var text: String = ""
    @State private var showCancel: Bool = false
    @State private var showNewClubCover: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var showCompletedApplicationToast:Bool = false
    
    @StateObject private var clubObserver = ClubObserver()
    
    @EnvironmentObject var session: SessionStore
    
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
                        if clubObserver.clubs.isEmpty {
                            Text("There are no clubs in your area. Broaden your search or...")
                                .font(.caption)
                                .padding(.top, 50)
                            Button(action:{ showNewClubCover.toggle() }){
                                Text("Create One?")
                                    .font(.caption)
                            }
                                
                        } else {
                            if text != ""{
                                ForEach(clubObserver.clubs.filter{$0.name.lowercased().contains(text.lowercased())}, id: \.id){ c in
                                    SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: clubObserver)
                                }
                            } else {
                                ForEach(clubObserver.clubs, id: \.id){ c in
                                    SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: clubObserver)
                                }
                            }
                        }
                    }
                }
            }.toast(isPresenting: $showCompletedApplicationToast){
                AlertToast(displayMode: .banner(.pop), type: .regular, title: "Application Sent!", style: .style(titleColor: .green, titleFont: .body))
            }
            .refreshable {
                let geoCoder = CLGeocoder()
                let location = session.locationManager.location
                
                if let loc = location {
                    let l = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                    do {
                        let pk = try await geoCoder.reverseGeocodeLocation(l)
                        if let country = pk.first?.country {
                            if let state = pk.first?.subAdministrativeArea{
                                await clubObserver.getClubs(country: country, state: state)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }.task {
            if session.clubs.isEmpty {
                let geoCoder = CLGeocoder()
                let location = session.locationManager.location
                
                if let loc = location {
                    let l = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                    do {
                        let pk = try await geoCoder.reverseGeocodeLocation(l)
                        if let country = pk.first?.country {
                            if let state = pk.first?.administrativeArea{
                                await clubObserver.getClubs(country: country, state: state)
                                await MainActor.run {
                                    session.clubs = clubObserver.clubs
                                    if !session.myClubs.isEmpty {
                                        for aClub in session.myClubs {
                                            clubObserver.clubs.removeAll(where: {$0.id == aClub.id})
                                        }
                                    }
                                    clubObserver.isLoading = false
                                    status = .success
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
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
