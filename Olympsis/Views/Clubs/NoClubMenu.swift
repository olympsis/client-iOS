//
//  NoClubMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import MapKit
import SwiftUI

struct NoClubMenu: View {
    
    @State private var showEula: Bool = false
    @State private var showNewClub: Bool = false
    @State private var showInvites: Bool = false
    
    @State private var area: String = "Unknown"
    @State private var region : MKCoordinateRegion = .init()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session:SessionStore
    
    var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
    func fetchLocaleInformation() async {
        let geoCoder = CLGeocoder()
        let location = session.locationManager.region
        let l = CLLocation(latitude: location.center.latitude, longitude: location.center.longitude)
        do {
            let pk = try await geoCoder.reverseGeocodeLocation(l)
            guard let _ = pk.first?.country,
                  let state = pk.first?.administrativeArea,
                  let _ = pk.first?.locality else {
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
                    Button(action:{
                        guard acceptedEULA else {
                            self.showEula.toggle()
                            return
                        }
                        self.showNewClub.toggle()
                    }) {
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
                        }
                    }.fullScreenCover(isPresented: $showNewClub) {
                        NewGroup()
                    }
                }
                .fullScreenCover(isPresented: $showEula, content: {
                    EndUserLicenseAgreement()
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{ dismiss() }){
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("color-prime"))
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)

            }
        }
    }
}

struct NoClubMenu_Previews: PreviewProvider {
    static var previews: some View {
        NoClubMenu()
            .environmentObject(SessionStore())
    }
}
