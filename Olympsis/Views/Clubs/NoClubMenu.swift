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
    
    @State private var sliderValue = 1.0
    @State private var showEula: Bool = false
    @State private var showNewClub: Bool = false
    @State private var showInvites: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var showChangeLocation: Bool = false
    
    @AppStorage("searchRadius") private var radius: Double? // search radius for fields/events in meters
    
    @State private var mapRegion: MKCoordinateRegion?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), latitudinalMeters: 4000, longitudinalMeters: 4000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), latitudinalMeters: 4000, longitudinalMeters: 4000)
    }
    
    private var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private func updateMapRegion() {
        guard let currentRadius = radius else { return }
        
        // Get the current center
        let center = session.locationManager.location ?? fallbackLocation.center
        
        // Calculate the span to show the radius with padding
        let radiusInDegrees = (currentRadius * 1.5) / 111320  // Convert meters to degrees with 50% padding
        
        // Account for longitude distortion at different latitudes
        let latitudinalPadding = radiusInDegrees
        let longitudinalPadding = radiusInDegrees / cos(center.latitude * .pi / 180.0)
        
        let newRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: latitudinalPadding * 1.5,
                longitudeDelta: longitudinalPadding * 1.5
            )
        )
        
        mapRegion = newRegion
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(newRegion)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                Map(position: $cameraPosition) {
                    // Add a MapCircle for precise radius visualization
                    MapCircle(
                        center: session.locationManager.location ?? fallbackLocation.center,
                        radius: radius ?? 5000
                    )
                    .strokeStyle(style: .init(lineWidth: 2, dash: [6, 6]))
                    .foregroundStyle(.blue.opacity(0.3))
                    
                    UserAnnotation()
                }
                .disabled(true)
                .padding(.top, 10)
                .frame(height: 250)
                .onChange(of: radius) { _, newValue in
                    withAnimation {
                        updateMapRegion()
                    }
                }
                .onAppear {
                    updateMapRegion()
                }
                
                VStack(alignment: .leading) {
                    Text("Search Radius:")
                        .bold()
                    HStack {
                        Slider(value: $sliderValue, in: 1...100, step: 1)
                            .tint(Color("color-prime"))
                        Text("\(Int(sliderValue)) miles")
                            .padding(.trailing)
                            .onChange(of: sliderValue) { _, newValue in
                                radius = milesToMeters(radius: sliderValue)
                            }
                    }
                }.padding()
                
                
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
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action:{
                        }){
                            LoadingButton(text: "Search", width: 70, status: $status)
                                .frame(width: 85)
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

#Preview {
    NoClubMenu(location: .constant([]))
        .environment(SessionStore())
}
