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
    
    @State var locations: [CLLocation] = []
    
    var body: some View {
        Map {
            MapPolyline(coordinates: locations.map { $0.coordinate })
                .tint(Color.blue)
                .stroke(Color.blue, lineWidth: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .frame(height: 300)
    }
}

#Preview {
    WorkoutMapView()
}
