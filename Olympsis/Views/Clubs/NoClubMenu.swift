//
//  NoClubMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import MapKit
import SwiftUI

struct NoClubMenu: View {
    
    @Binding var status: LOADING_STATE
    @State private var showNewClub: Bool = false
    @State private var showInvites: Bool = false
    
    @State private var area: String = "Unknown"
    @State var trackingMode: MapUserTrackingMode = .follow
    @State var region : MKCoordinateRegion = .init()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func fetchLocaleInformation() async {
        let geoCoder = CLGeocoder()
        let location = session.locationManager.region
        let l = CLLocation(latitude: location.center.latitude, longitude: location.center.longitude)
        do {
            let pk = try await geoCoder.reverseGeocodeLocation(l)
            guard let country = pk.first?.country,
                  let state = pk.first?.administrativeArea,
                  let city = pk.first?.locality else {
                return
            }
            area = state
        } catch {
            return
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
//                    Map(coordinateRegion: $session.locationManager.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $trackingMode)
//                        .frame(height: 300)
//                        .padding(.vertical)
//                        .overlay(alignment:  .bottomTrailing) {
//                            Button(action: { Task { await fetchLocaleInformation() } }) {
//                                Text("Set Area")
//                                    .foregroundStyle(.white)
//                            }
//                            .padding(.horizontal)
//                            .padding(.vertical, 5)
//                            .background {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .foregroundColor(Color("color-prime"))
//                            }
//                            .padding(.all, 20)
//                            .padding(.bottom, 20)
//                        }
//                    
//                    Text("Region: \(area)")
                    
                    Button(action:{self.showNewClub.toggle()}) {
                        HStack {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading){
                                Text("Create a New Group")
                                    .foregroundColor(.primary)
                                Text("Where athletes come together")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }.modifier(MenuButton())
                    }.fullScreenCover(isPresented: $showNewClub) {
                        NewGroup()
                    }
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("color-prime"))
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct NoClubMenu_Previews: PreviewProvider {
    static var previews: some View {
        NoClubMenu(status: .constant(.failure))
            .environmentObject(SessionStore())
    }
}
