//
//  ActivityStateButtons.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/15/25.
//

import SwiftUI

struct ActivityStateButtons: View {
    
    @Binding var selection: ACTIVITY_PAGES
    @Environment(WorkoutManager.self) private var manager
    @State private var isInteractionDisabled = false
    
    private var isPaused: Bool {
        return manager.state == .paused
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Stop button - appears when paused
            if isPaused {
                Button(action: {
                    manager.stopWorkout()
                }) {
                    Group {
                        if manager.isProcessingWorkout {
                            ProgressView()
                        } else {
                            Image(systemName: "stop.fill")
                        }
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 75, height: 75)
                    .background(Color.red)
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .scaleEffect(isPaused ? 1.0 : 0.1)
                .opacity(isPaused ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: isPaused)
            }
            
            // Play/Pause button
            Button(action: {
                // Prevent action during workout processing, state transitions, or when interaction is disabled
                guard !manager.isProcessingWorkout && !isInteractionDisabled else { return }
                
                // Temporarily disable interactions to prevent rapid-fire clicks
                isInteractionDisabled = true
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                    isPaused ? manager.resumeWorkout() : manager.pauseWorkout()
                    selection = isPaused ? .details : .menu
                }
                
                // Re-enable interactions after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isInteractionDisabled = false
                }
            }) {
                Image(systemName:isPaused  ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .frame(height: 75)
                    .frame(maxWidth: isPaused ? 75 : .infinity)
                    .background(Color.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: isPaused ? 100 : 30))
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5), value: isPaused)
        }.disabled(manager.isProcessingWorkout || isInteractionDisabled)
    }
}

#Preview {
    ActivityStateButtons(selection: .constant(.menu))
        .environment(WorkoutManager())
}
