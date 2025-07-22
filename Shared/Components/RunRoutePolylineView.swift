//
//  RunRoutePolylineView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/22/25.
//

import SwiftUI
import CoreLocation

struct RunRoutePolylineView: View {
    let coordinates: [CLLocationCoordinate2D]
    var lineColor: Color = Color.Brand.primary
    var lineWidth: CGFloat = 5
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard coordinates.count > 1 else { return }
                
                // Convert coordinates to view points
                let points = coordinatesToPoints(coordinates, in: geometry.size)
                
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }.stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            
            // Optional: Add start and end markers
            if let points = coordinatesToPoints(coordinates, in: geometry.size) as [CGPoint]?,
               points.count > 0 {
                // Start marker (green)
                Circle()
                    .stroke(Color.Brand.primary, lineWidth: 3)
                    .frame(width: 8, height: 8)
                    .position(points.first!)
                
                // End marker (red)
                if points.count > 1 {
                    Circle()
                        .stroke(Color.Brand.primary, lineWidth: 3)
                        .frame(width: 8, height: 8)
                        .position(points.last!)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func coordinatesToPoints(_ coords: [CLLocationCoordinate2D], in size: CGSize) -> [CGPoint] {
        guard !coords.isEmpty else { return [] }
        
        let latitudes = coords.map { $0.latitude }
        let longitudes = coords.map { $0.longitude }
        
        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!
        
        // Add padding to prevent clipping at edges
        let padding: Double = 0.5
        let latRange = max((maxLat - minLat) * (1 + padding), 0.001)
        let lonRange = max((maxLon - minLon) * (1 + padding), 0.001)
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        return coords.map { coord in
            let normalizedX = (coord.longitude - (centerLon - lonRange/2)) / lonRange
            let normalizedY = 1.0 - (coord.latitude - (centerLat - latRange/2)) / latRange
            
            let x = CGFloat(normalizedX) * size.width
            let y = CGFloat(normalizedY) * size.height
            
            return CGPoint(x: x, y: y)
        }
    }
}

#Preview {
    RunRoutePolylineView(coordinates: RUNNING_POINTS.map { $0.coordinate })
}
