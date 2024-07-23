//
//  ActivityGoalButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityGoalButton: View {
    
    var goal: ACTIVITY_GOALS
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 45)
            .foregroundStyle(Color.foreground)
            .overlay {
                HStack {
                    Text(goal.toString())
                        .textCase(.uppercase)
                        .font(.title3)
                        .italic()
                        .fontWeight(.bold)
                        .foregroundStyle(Color.background)
                    
                    Spacer()
                    
                    goal.toIcon()
                        .fontWeight(.bold)
                        .foregroundStyle(Color.background)
                }
                .padding(.horizontal)
            }
    }
}

#Preview {
    ActivityGoalButton(goal: .duration)
}
