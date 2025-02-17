//
//  MapOptions.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import MapKit
import SwiftUI
import CoreLocation

struct EventsOptions: View {
    
    @State var availableSports:[SPORTS]
    @State var selectedSports: [SPORTS] = [SPORTS]()
    @State private var status: LOADING_STATE = .pending
    @State private var sliderValue = 1.0
    
    @EnvironmentObject private var router: EventRouter
    @Environment(SessionStore.self) private var session
    
    @AppStorage("searchRadius") private var radius: Double? // search radius for fields/events in meters
    
    @State private var mapRegion: MKCoordinateRegion?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), latitudinalMeters: 4000, longitudinalMeters: 4000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), latitudinalMeters: 4000, longitudinalMeters: 4000)
    }
    
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
    
    func NewSearch() async {
        if let location = session.locationManager.location {
            await session.getNearbyData(location: location, selectedSports: selectedSports.map { $0.rawValue })
            return
        } else if let hometown = session.user?.hometown {
            await session.getNearbyData(location: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), selectedSports: selectedSports.map { $0.rawValue })
        } else {
            await session.getNearbyData(location: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), selectedSports: selectedSports.map { $0.rawValue })
        }
    }
    
    var body: some View {
        VStack {            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    HStack {
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
                    }
                    
                    Text("Search Radius:")
                        .bold()
                        .padding(.top, 20)
                        .padding(.leading)
                    HStack {
                        Slider(value: $sliderValue, in: 1...100, step: 1)
                            .tint(Color("color-prime"))
                        Text("\(Int(sliderValue)) miles")
                            .padding(.trailing)
                            .onChange(of: sliderValue) { _, newValue in
                                radius = milesToMeters(radius: sliderValue)
                            }
                    }
                    .padding(.leading)
                    
                    Text("Sports:")
                        .bold()
                        .padding(.leading)
                    
                    SportsPicker(selectedSports: $selectedSports, multiSelection: true)
                }
            }.background(Color.Background.primary)
        }
        .task {
            cameraPosition = .userLocation(fallback: .region(fallbackLocation))
            guard let radiusValue = radius else { return }
            sliderValue = metersToMiles(radius: radiusValue)
            updateMapRegion()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { self.router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                    
                }
                .clipShape(Circle())
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action:{
                    Task {
                        await MainActor.run {
                            self.status = .loading
                        }
                        await NewSearch()
                        await MainActor.run {
                            self.status = .success
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            self.router.navigateBack()
                        }
                    }
                }){
                    LoadingButton(text: "Search", width: 100, status: $status)
                        .frame(width: 100)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        EventsOptions(availableSports: [SPORTS.soccer, SPORTS.basketball, SPORTS.golf], selectedSports: [.soccer, .basketball, .pickleball])
            .environmentObject(EventRouter())
            .environment(SessionStore())
            .navigationBarBackButtonHidden(false)
    }
}
