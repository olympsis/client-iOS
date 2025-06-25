//
//  WorkoutSplitView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/24/25.
//

import SwiftUI

struct WorkoutSplitView: View {
    
    var segments: [PaceSegment]
    
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    WorkoutSplitView(segments: [
        PaceSegment(segmentNumber: 1, distance: 1, duration: 5, pace: 500, elevationGain: 0, elevationLoss: 0, startTime: Date(), endTime: Date())
    ])
}
