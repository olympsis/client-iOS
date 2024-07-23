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
    @EnvironmentObject private var manager: ActivityManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - STOP & PAUSE
                HStack(spacing: 20) {
                    Button(action: {
                        manager.stopWorkout()
                    }) {
                        Circle()
                            .foregroundStyle(.red)
                            .overlay {
                                if !manager.isProcessingWorkout {
                                    Image(systemName: "stop.fill")
                                        .imageScale(.large)
                                } else {
                                    ProgressView()
                                }
                            }
                    }
                    .frame(width: 75, height: 75)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(manager.isProcessingWorkout)
                    
                    Button(action: {
                        withAnimation {
                            if manager.state == .paused {
                                manager.resumeWorkout()
                                selection = .metrics
                            } else {
                                manager.pauseWorkout()
                                selection = .details
                            }
                        }
                    }) {
                        Circle()
                            .foregroundStyle(Color.background)
                            .overlay {
                                if manager.state == .paused {
                                    Image(systemName: "play.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.foreground)
                                } else {
                                    Image(systemName: "pause.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.foreground)
                                }
                            }
                    }
                    .frame(width: 75, height: 75)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(manager.isProcessingWorkout)
                }
                
                // MARK: - Water & Lap
                HStack(spacing: 20) {
                    Button(action: {}) {
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
                    
                    Button(action: {}) {
                        Circle()
                            .foregroundStyle(Color.colorSecnd)
                            .overlay {
                                Image(systemName: "flag.checkered")
                                    .imageScale(.large)
                            }
                            
                    }
                    .frame(width: 75, height: 75)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(manager.isProcessingWorkout)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Menu")
                }
            }
        }
    }
}

#Preview {
    ActivityMenu(selection: .constant(.menu))
        .environmentObject(ActivityManager())
}
