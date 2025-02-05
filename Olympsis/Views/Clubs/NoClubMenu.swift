//
//  NoClubMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import MapKit
import SwiftUI

struct NoClubMenu: View {
    
    @Binding var location: [Double]
    
    @State private var showEula: Bool = false
    @State private var showNewClub: Bool = false
    @State private var showInvites: Bool = false
    @State private var showChangeLocation: Bool = false
    
    @State private var region : MKCoordinateRegion = .init()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
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
                    }
                    
                    Button(action:{
                        location = []
                        self.showChangeLocation.toggle()
                    }) {
                        HStack {
                            Image(systemName: "globe.americas")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading){
                                Text("Change Location")
                                    .foregroundColor(.primary)
                                Text("Look for clubs in other locations")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                }
                .fullScreenCover(isPresented: $showNewClub) {
                    NewGroup()
                }
                .fullScreenCover(isPresented: $showChangeLocation) {
                    HometownPicker(hometown: $location)
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

            }.background(Color("background-color/primary"))
        }
    }
}

#Preview {
    NoClubMenu(location: .constant([]))
        .environment(SessionStore())
}
