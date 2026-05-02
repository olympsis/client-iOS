//
//  ActivityMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI
import WatchKit

struct ActivityMenu: View {
    
    @Binding var selection: ACTIVITY_PAGES
    @Environment(WorkoutManager.self) private var manager
    
    private var isPaused: Bool {
        return manager.state == .paused
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // MARK: - STOP & PAUSE
            ActivityStateButtons(selection: $selection)
                .environment(manager)
            
            // MARK: - Water & Lap
            HStack(spacing: 20) {
                Button(action: { manager.enableWaterEjectMode() }) {
                    Circle()
                        .foregroundStyle(Color.colorPrime)
                        .overlay {
                            Image(systemName: "drop.fill")
                                .imageScale(.large)
                        }
                }
                .frame(width: 75, height: 75)
                .buttonStyle(PlainButtonStyle())
                .disabled(manager.isProcessingWorkout)
                
//                    Button(action: {}) {
//                        Circle()
//                            .foregroundStyle(Color.colorSecnd)
//                            .overlay {
//                                Image(systemName: "flag.checkered")
//                                    .imageScale(.large)
//                            }
//
//                    }
//                    .frame(width: 75, height: 75)
//                    .buttonStyle(PlainButtonStyle())
//                    .disabled(manager.isProcessingWorkout)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(manager.state == .paused ? "Menu - Paused" : "Menu - Active")
                    .foregroundStyle(manager.state == .paused ? Color.Brand.secondary : .primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ActivityMenu(selection: .constant(.menu))
            .environment(WorkoutManager())
    }
}
