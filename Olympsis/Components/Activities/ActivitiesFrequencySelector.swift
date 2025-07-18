//
//  ActivityFrequencySelector.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/21/25.
//

import SwiftUI

struct ActivitiesFrequencySelector: View {
    
    @Binding var selectedFilter: Int
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.interpolatingSpring) {
                    manager.selectedFilter = 0
                }
            }){
                Text("Week")
                    .foregroundColor(manager.selectedFilter == 0 ? .white : .primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(manager.selectedFilter == 0 ? Color.Brand.primary : Color.primary)
                    .opacity(manager.selectedFilter == 0 ? 1 : 0.15)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 1)
                    .opacity(0.25)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.interpolatingSpring) {
                    manager.selectedFilter = 1
                }
            }){
                Text("Month")
                    .foregroundColor(manager.selectedFilter == 1 ? .white : .primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(manager.selectedFilter == 1 ? Color.Brand.primary : Color.primary)
                    .opacity(manager.selectedFilter == 1 ? 1 : 0.15)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 1)
                    .opacity(0.25)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.interpolatingSpring) {
                    manager.selectedFilter = 2
                }
            }){
                Text("Year")
                    .foregroundColor(manager.selectedFilter == 2 ? .white : .primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(manager.selectedFilter == 2 ? Color.Brand.primary : Color.primary)
                    .opacity(manager.selectedFilter == 2 ? 1 : 0.15)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 1)
                    .opacity(0.25)
            }
        }
        .padding(.horizontal, 7)
    }
}

#Preview {
    ActivitiesFrequencySelector(selectedFilter: .constant(1))
        .environment(WorkoutManager())
}
