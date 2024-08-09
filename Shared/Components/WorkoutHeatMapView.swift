//
//  WorkoutHeatMapView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/7/24.
//

import UIKit
import MapKit
import SwiftUI
import Foundation
import CoreLocation

struct HeatmapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    @State private var coordinates: [CLLocationCoordinate2D] = RUNNING_POINTS
    @State private var annotations: [HeatmapAnnotation] = []
    var body: some View {
        Map {
            ForEach(annotations) { annotation in
                Annotation(coordinate: annotation.coordinate) {
                    Circle()
                        .fill(annotation.color)
                        .frame(width: 20, height: 20)
                        .opacity(0.5)
                } label: {
                    EmptyView()
                }
            }
        }
        .task {
            annotations = createHeatmapAnnotations(from: RUNNING_POINTS)
        }
    }

    private func createHeatmapAnnotations(from coordinates: [CLLocationCoordinate2D]) -> [HeatmapAnnotation] {
        // Define grid size
        let gridSize = 0.1 // Adjust this value to change the size of the grid cells

        // Create a dictionary to count the number of points in each grid cell
        var gridCount = [String: Int]()

        for coordinate in coordinates {
            let gridX = Int(coordinate.latitude / gridSize)
            let gridY = Int(coordinate.longitude / gridSize)
            let key = "\(gridX)-\(gridY)"
            gridCount[key, default: 0] += 1
        }

        // Create annotations for each grid cell
        var annotations = [HeatmapAnnotation]()
        for (key, count) in gridCount {
            let parts = key.split(separator: "-").map { Int($0)! }
            let gridX = parts[0]
            let gridY = parts[1]

            let coordinate = CLLocationCoordinate2D(latitude: Double(gridX) * gridSize, longitude: Double(gridY) * gridSize)
            let color = Color(red: 1.0, green: 1.0 - min(Double(count) / 10.0, 1.0), blue: 0.0) // Adjust color based on density

            let annotation = HeatmapAnnotation(coordinate: coordinate, color: color)
            annotations.append(annotation)
        }

        return annotations
    }
}

struct HeatmapAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var color: Color
}

#Preview {
    HeatmapView()
}
