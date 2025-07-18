//
//  WorkoutHeatmapView.swift
//  Olympsis
//
//  Created by Claude on 6/26/25.
//

import SwiftUI
import CoreLocation

struct WorkoutHeatmapView: View {
    // MARK: - Properties
    
    /// The GPS coordinates to visualize (workout tracking points)
    let coordinates: [CLLocationCoordinate2D]
    
    /// Optional field boundary coordinates for focused mapping
    let fieldBounds: [CLLocationCoordinate2D]?
    
    /// Sport type for customized visualization
    let sportType: String?
    
    /// Grid dimensions for the heatmap (reduced for better performance)
    private let gridSize = 30
    
    /// Heat intensity levels for color mapping
    private let maxHeatIntensity = 10.0
    
    /// State for heatmap data with loading management
    @State private var heatmapData: [[Double]] = []
    @State private var isLoading = true
    
    /// Computed property for the mapping bounds (either field bounds or coordinate bounds)
    private var mappingBounds: (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) {
        calculateMappingBounds()
    }
    
    // MARK: - Initializers
    
    /// Initialize with coordinates only (uses coordinate bounds for mapping)
    init(coordinates: [CLLocationCoordinate2D], sportType: String? = nil) {
        self.coordinates = coordinates
        self.fieldBounds = nil
        self.sportType = sportType
    }
    
    /// Initialize with coordinates and field bounds (uses field bounds for focused mapping)
    init(coordinates: [CLLocationCoordinate2D], fieldBounds: [CLLocationCoordinate2D], sportType: String? = nil) {
        self.coordinates = coordinates
        self.fieldBounds = fieldBounds
        self.sportType = sportType
    }
    
    /// Convenience initializer using RUNNING_POINTS from TempData
    init(sportType: String? = nil) {
        self.coordinates = RUNNING_POINTS
        self.fieldBounds = nil
        self.sportType = sportType
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with sport-specific text
            Text(titleText)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Subtitle explanation with sport context
            Text(subtitleText)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // The actual heatmap grid
            if isLoading {
                // Loading state
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Generating heatmap...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                ScrollView([.horizontal, .vertical]) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(10), spacing: 1), count: gridSize), spacing: 1) {
                        ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                            let row = index / gridSize
                            let col = index % gridSize
                            Rectangle()
                                .fill(colorForHeatValue(heatmapData[row][col]))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 400)
            }
            
            // Legend
            HeatmapLegend()
                .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            generateHeatmapAsync()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Dynamic title based on sport type
    private var titleText: String {
        if let sport = sportType {
            return "\(sport.capitalized) Activity Heatmap"
        }
        return "Workout Activity Heatmap"
    }
    
    /// Dynamic subtitle based on sport and field bounds
    private var subtitleText: String {
        if fieldBounds != nil {
            return "Activity intensity within the playing area"
        } else if let sport = sportType {
            return "Shows where you spent most time during your \(sport) session"
        }
        return "Shows where you spent most time during your workout"
    }
    
    // MARK: - Heatmap Generation
    
    /// Generates the heatmap data asynchronously to avoid blocking the main thread
    private func generateHeatmapAsync() {
        isLoading = true
        
        Task {
            let data = await generateHeatmapData()
            await MainActor.run {
                self.heatmapData = data
                self.isLoading = false
            }
        }
    }
    
    /// Generates the heatmap data by analyzing GPS points and calculating density
    private func generateHeatmapData() async -> [[Double]] {
        // Initialize empty grid
        var grid = Array(repeating: Array(repeating: 0.0, count: gridSize), count: gridSize)
        
        // Early return if no coordinates
        guard !coordinates.isEmpty else { return grid }
        
        // Use the calculated mapping bounds
        let bounds = mappingBounds
        
        // Calculate ranges for mapping coordinates to grid positions
        let latRange = bounds.maxLat - bounds.minLat
        let lonRange = bounds.maxLon - bounds.minLon
        
        // Prevent division by zero for very small ranges
        guard latRange > 0 && lonRange > 0 else { return grid }
        
        // Process each GPS point
        for coordinate in coordinates {
            // Map GPS coordinates to grid positions (0 to gridSize-1)
            let gridX = Int((coordinate.longitude - bounds.minLon) / lonRange * Double(gridSize - 1))
            let gridY = Int((coordinate.latitude - bounds.minLat) / latRange * Double(gridSize - 1))
            
            // Ensure we're within grid bounds
            let clampedX = max(0, min(gridSize - 1, gridX))
            let clampedY = max(0, min(gridSize - 1, gridY))
            
            // Add heat to this grid cell and surrounding cells for smoothing
            addHeatToGrid(&grid, x: clampedX, y: clampedY)
        }
        
        return grid
    }
    
    /// Calculates the mapping bounds (either field bounds or coordinate bounds)
    private func calculateMappingBounds() -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) {
        // If field bounds are provided, use them for focused mapping
        if let fieldBounds = fieldBounds, !fieldBounds.isEmpty {
            let minLat = fieldBounds.map { $0.latitude }.min()!
            let maxLat = fieldBounds.map { $0.latitude }.max()!
            let minLon = fieldBounds.map { $0.longitude }.min()!
            let maxLon = fieldBounds.map { $0.longitude }.max()!
            
            // Add small padding around field bounds for better visualization
            let latPadding = (maxLat - minLat) * 0.1
            let lonPadding = (maxLon - minLon) * 0.1
            
            return (
                minLat: minLat - latPadding,
                maxLat: maxLat + latPadding,
                minLon: minLon - lonPadding,
                maxLon: maxLon + lonPadding
            )
        }
        
        // Otherwise, use the bounds of the coordinate data
        guard !coordinates.isEmpty else {
            return (minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)
        }
        
        let minLat = coordinates.map { $0.latitude }.min()!
        let maxLat = coordinates.map { $0.latitude }.max()!
        let minLon = coordinates.map { $0.longitude }.min()!
        let maxLon = coordinates.map { $0.longitude }.max()!
        
        return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
    }
    
    /// Adds heat to a specific grid cell and surrounding cells for smoothing effect
    private func addHeatToGrid(_ grid: inout [[Double]], x: Int, y: Int) {
        // Define the influence radius (how far heat spreads from each point)
        let influenceRadius = 2
        
        for dy in -influenceRadius...influenceRadius {
            for dx in -influenceRadius...influenceRadius {
                let newX = x + dx
                let newY = y + dy
                
                // Check if the new position is within grid bounds
                if newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize {
                    // Calculate distance from center point
                    let distance = sqrt(Double(dx * dx + dy * dy))
                    
                    // Calculate heat intensity based on distance (closer = more heat)
                    let heatIntensity = max(0.0, 1.0 - (distance / Double(influenceRadius)))
                    
                    // Add heat to the grid cell
                    grid[newY][newX] += heatIntensity
                }
            }
        }
    }
    
    /// Returns the appropriate color for a given heat value
    private func colorForHeatValue(_ value: Double) -> Color {
        // Normalize the value to 0-1 range
        let normalizedValue = min(1.0, value / maxHeatIntensity)
        
        // Create color gradient from blue (cold) to red (hot)
        if normalizedValue == 0 {
            return Color.clear // No activity
        } else if normalizedValue < 0.2 {
            return Color.blue.opacity(0.3) // Low activity
        } else if normalizedValue < 0.4 {
            return Color.cyan.opacity(0.5) // Low-medium activity
        } else if normalizedValue < 0.6 {
            return Color.green.opacity(0.7) // Medium activity
        } else if normalizedValue < 0.8 {
            return Color.yellow.opacity(0.8) // High activity
        } else {
            return Color.red.opacity(0.9) // Very high activity
        }
    }
}

// MARK: - Heatmap Legend

/// Legend component to explain the heatmap colors
struct HeatmapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity Level")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                LegendItem(color: .blue, label: "Low")
                LegendItem(color: .cyan, label: "Medium")
                LegendItem(color: .green, label: "High")
                LegendItem(color: .yellow, label: "Very High")
                LegendItem(color: .red, label: "Highest")
            }
        }
    }
}

/// Individual legend item component
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color.opacity(0.7))
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

struct WorkoutHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Example 1: Basic usage with sport type
                WorkoutHeatmapView(sportType: "soccer")
                
                // Example 2: With custom coordinates
                WorkoutHeatmapView(coordinates: RUNNING_POINTS, sportType: "tennis")
                
                // Example 3: With field bounds for focused mapping
                WorkoutHeatmapView(
                    coordinates: RUNNING_POINTS,
                    fieldBounds: createSampleFieldBounds(),
                    sportType: "tennis"
                )
            }
        }
        .padding()
    }
    
    /// Creates sample field bounds for preview (tennis court example)
    static func createSampleFieldBounds() -> [CLLocationCoordinate2D] {
        // Sample tennis court bounds (rectangle around the activity area)
        let centerLat = 40.76090
        let centerLon = -111.86110
        let courtLength = 0.0003 // Approximate degrees for tennis court
        let courtWidth = 0.0002
        
        return [
            CLLocationCoordinate2D(latitude: centerLat - courtLength/2, longitude: centerLon - courtWidth/2), // Bottom-left
            CLLocationCoordinate2D(latitude: centerLat - courtLength/2, longitude: centerLon + courtWidth/2), // Bottom-right
            CLLocationCoordinate2D(latitude: centerLat + courtLength/2, longitude: centerLon + courtWidth/2), // Top-right
            CLLocationCoordinate2D(latitude: centerLat + courtLength/2, longitude: centerLon - courtWidth/2)  // Top-left
        ]
    }
}
