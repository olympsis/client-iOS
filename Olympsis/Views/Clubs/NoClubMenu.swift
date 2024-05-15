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
    @State private var region : MKCoordinateRegion = .init()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
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
                        }
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
