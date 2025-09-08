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
        }
    }
}

#Preview {
    CustomLocationPicker()
        .environment(CustomLocationViewModel())
}
