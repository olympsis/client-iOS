//
//  CountdownView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/14/25.
//

import SwiftUI

struct ActivityCountdownView: View {
    
    @Binding var isActive: Bool
    @State private var countdown: Int = 3
    @Environment(WorkoutManager.self) private var manager
    
    private func startCountdown() {
        if manager.session == nil {
            manager.prepareWorkout()
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdown > 1 {
                    countdown -= 1
                } else {
                    isActive = false
                    timer.invalidate()
                    Task {
                        await manager.startWorkout()
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.Brand.primary
                .ignoresSafeArea()
            
            Text("\(countdown)")
                .font(.custom("Archivo-Black", size: 150))
                .fontWeight(.bold)
                .padding(.bottom)
                .padding(.bottom)
            
        }
        .onAppear(perform: startCountdown)
        .zIndex(100)
    }
}

#Preview {
    ActivityCountdownView(isActive: .constant(true))
        .environment(WorkoutManager())
}
