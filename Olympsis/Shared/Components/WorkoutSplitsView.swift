import SwiftUI

struct WorkoutSplitsView: View {
    
    var splits: [DistanceSplit]
    var unit: UnitLength = .miles
    var hasElevationData: Bool = false
    
    private var mileData: [(mile: String, pace: String, elevation: String, barWidth: CGFloat)] {
        var result: [(String, String, String, CGFloat)] = []
        var cumulativeDistance = 0.0
        
        // Calculate relative bar widths based on pace
        let paces = splits.map { $0.pace }
        let minPace = paces.min() ?? 0
        let maxPace = paces.max() ?? 1
        let paceRange = maxPace - minPace
        
        for split in splits {
            let splitDistanceInMiles = split.distance / 1609.344
            cumulativeDistance += splitDistanceInMiles
            
            // Determine mile display
            let mileDisplay: String
            if splitDistanceInMiles >= 1.0 {
                // Full mile
                mileDisplay = String(Int(cumulativeDistance))
            } else {
                // Partial mile - show decimal
                mileDisplay = String(format: "%.2f", splitDistanceInMiles)
            }
            
            // Format pace as MM:SS
//            let minutes = split.pace / 60
//            let seconds = split.pace % 60
//            let paceDisplay = String(format: "%d:%02d", minutes, seconds)
            
            // Format elevation
            let elevationDisplay = hasElevationData ? "\(split.elevation) ft" : ""
            
            // Calculate bar width (faster pace = longer bar)
            let normalizedPace = paceRange > 0 ? CGFloat(maxPace - split.pace) / CGFloat(paceRange) : 1.0
            let barWidth = SCREEN_WIDTH/4 + (normalizedPace * SCREEN_WIDTH/4) // Min 60pt, max 120pt
            
            result.append((mileDisplay, String(format: "%.2f", Double(split.pace/60)), elevationDisplay, barWidth))
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("SPLITS")
                    .font(.custom("Archivo-Bold", size: 16))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // Column headers
            HStack {
                Text("MI")
                    .font(.custom("Archivo-Medium", size: 13))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                
                Spacer()
                
                Text("PACE")
                    .font(.custom("Archivo-Medium", size: 13))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if hasElevationData {
                    Text("ELEVATION")
                        .font(.custom("Archivo-Medium", size: 13))
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .trailing)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Data rows
            ForEach(Array(mileData.enumerated()), id: \.offset) { index, data in
                HStack {
                    // Mile column
                    Text(data.mile)
                        .font(.custom("Archivo-Regular", size: 16))
                        .foregroundColor(.primary)
                        .frame(width: 40, alignment: .leading)
                    
                    // Pace with background bar
                    ZStack(alignment: .leading) {
                        // Background bar (similar to image)
                        Rectangle()
                            .fill(Color.Brand.primary)
                            .frame(height: 25)
                            .frame(width: data.barWidth)
                        
                        // Pace text
                        Text(data.pace)
                            .font(.custom("Archivo-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    
                    Spacer()
                    
                    // Elevation column
                    if hasElevationData {
                        Text(data.elevation)
                            .font(.custom("Archivo-Regular", size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    WorkoutSplitsView(
        splits: [
            DistanceSplit(id: 1, pace: 510, distance: 1609.344, elevation: 3),
            DistanceSplit(id: 2, pace: 525, distance: 1609.344, elevation: 0),
            DistanceSplit(id: 3, pace: 530, distance: 1609.344, elevation: -3),
            DistanceSplit(id: 4, pace: 515, distance: 852.27, elevation: -14) // 0.53 mile split
        ],
        hasElevationData: true
    )
}
