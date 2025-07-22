//
//  RunningMapView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/6/24.
//

import os
import MapKit
import SwiftUI
import HealthKit

struct WorkoutMapView: View {
    
    var gradient: [Color]
    var locations: [CLLocationCoordinate2D]
    
    var body: some View {
        Map {
            MapPolyline(coordinates: locations)
                .tint(Color.blue)
                .stroke(
                    Gradient(colors: gradient),
                    lineWidth: 2
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .frame(height: 250)
        .mapControlVisibility(.hidden)
        .disabled(true)
    }
}

#Preview {
    WorkoutMapView(gradient: [Color.Brand.primary], locations: ACTIVITY_POINTS)
}


