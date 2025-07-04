import SwiftUI

struct WorkoutSplitsView: View {
    
    var splits: [PaceSegment]
    var unit: UnitLength = .miles
    var hasElevationData: Bool = false
    
    private var mileData: [(mile: String, pace: String, elevation: String, barWidth: CGFloat)] {
        var result: [(String, String, String, CGFloat)] = []
        
        // Calculate relative bar widths based on pace
        let paces = splits.map { $0.getPace(for: unit) }
        let minPace = paces.min() ?? 0
        let maxPace = paces.max() ?? 1
        let paceRange = maxPace - minPace
        
        // Determine conversion factor based on unit
        let conversionFactor: Double = unit == .kilometers ? 1000.0 : 1609.344
        
        for (index, split) in splits.enumerated() {
            let splitDistanceInUnit = split.distance / conversionFactor
            
            // Sequential split numbering
            let mileDisplay: String
            if splitDistanceInUnit >= 1.0 {
                // Full unit - show split number
                mileDisplay = String(index + 1)
            } else {
                // Partial unit - show actual distance
                mileDisplay = String(format: "%.2f", splitDistanceInUnit)
            }
            
            // Format pace as MM:SS
            let paceInSeconds = split.getPace(for: unit)
            let minutes = Int(paceInSeconds) / 60
            let seconds = Int(paceInSeconds) % 60
            let paceDisplay = String(format: "%d:%02d", minutes, seconds)
            
            // Format elevation
            let elevation = split.elevationGain + split.elevationLoss
            let elevationDisplay = hasElevationData ? "\(elevation) ft" : ""
            
            // Calculate bar width (faster pace = longer bar)
            let normalizedPace = paceRange > 0 ? CGFloat(maxPace - split.getPace(for: unit)) / CGFloat(paceRange) : 1.0
            let barWidth = SCREEN_WIDTH/4 + (normalizedPace * SCREEN_WIDTH/4)
            
            result.append((mileDisplay, paceDisplay, elevationDisplay, barWidth))
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Splits")
                    .font(.custom("Archivo-Bold", size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // Column headers
            HStack {
                Text(unit == .miles ? "MI" : "KM")
                    .font(.custom("Archivo-Medium", size: 13))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                
                Text("PACE")
                    .padding(.leading)
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
        }.background(Color(.systemBackground))
    }
}

#Preview {
    WorkoutSplitsView(
        splits: [
            PaceSegment(segmentNumber: 1, distance: 1609.344, duration: 510, elevationGain: 10, elevationLoss: -5, startTime: Date(), endTime: Date()),
            PaceSegment(segmentNumber: 2, distance: 1609.344, duration: 530, elevationGain: 0, elevationLoss: -13.1, startTime: Date(), endTime: Date()),
            PaceSegment(segmentNumber: 3, distance: 1609.344, duration: 480, elevationGain: 0, elevationLoss: 0, startTime: Date(), endTime: Date()),
            PaceSegment(segmentNumber: 4, distance: 850.134, duration: 450, elevationGain: 0, elevationLoss: 0, startTime: Date(), endTime: Date()),
        ],
        unit: .miles,
        hasElevationData: true
    )
}
