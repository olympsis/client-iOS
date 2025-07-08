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
    
    @State var locations: [CLLocationCoordinate2D] = RUNNING_POINTS
    
    var body: some View {
        Map {
            MapPolyline(coordinates: locations)
                .tint(Color.blue)
                .stroke(Color.blue, lineWidth: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .frame(height: 250)
        .mapControlVisibility(.hidden)
        .disabled(true)
    }
}

#Preview {
    WorkoutMapView()
}


