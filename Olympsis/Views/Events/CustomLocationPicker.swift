//
//  CustomLocationPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/4/25.
//

import MapKit
import SwiftUI

struct CustomLocationPicker: View {
    
    @State private var position: MapCameraPosition = .automatic
    @Environment(CustomLocationViewModel.self) private var viewModel
    
    private func handleLocationTap(_ coordinate: CLLocationCoordinate2D) {
        // Update camera position to center on the tapped location
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
        
        // Lookup location information
        viewModel.lookupLocationInfo(for: coordinate)
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                // Show a marker if a location is selected
                if let coordinate = viewModel.selectedCoordinate {
                    Marker(String(localized: "selected-location-text", table: "General"), coordinate: coordinate)
                }
            }
            .onTapGesture(count: 1, coordinateSpace: .local,perform: { screenCoord in
                if let coordinate = proxy.convert(screenCoord, from: .local) {
                    handleLocationTap(coordinate)
                }
            })
            .ignoresSafeArea(edges: .bottom)
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            // On first appear, await a Core Location fix (up to 1s)
            // and snap the camera to it. We can't rely on
            // `MapCameraPosition.userLocation(fallback:)` here — its
            // follow mode only re-centers on the *next* CL update, so
            // when permission is already granted and a fix is cached
            // the camera can sit on the fallback region indefinitely.
            // The `.automatic` guard means we only do this on launch:
            // once the user pans the map themselves we don't yank
            // them back.
            .task {
                guard case .automatic = position else { return }
                LocationManager.shared.requestLocation()
                _ = await LocationManager.shared.waitForLocation(timeout: 1.0)
                let coord = LocationManager.shared.location
                    ?? CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988)
                withAnimation {
                    position = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    CustomLocationPicker()
        .environment(CustomLocationViewModel())
}
