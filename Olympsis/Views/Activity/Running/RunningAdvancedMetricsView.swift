//
//  RunningAdvancedMetricsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/24.
//

import SwiftUI

struct RunningAdvancedMetricsView: View {
    
    @Binding var selectedTab: WORKOUT_TABS
    
    var body: some View {
        VStack {
            HStack {
                Text("Metrics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }.padding(.horizontal)
            
            RunningSplits(splits: [RunSplit]())
                .padding(.vertical)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    selectedTab = .metrics
                }
            }) {
                Circle()
                    .foregroundStyle(.colorSecnd)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .foregroundStyle(Color.background)
                    }
            }.padding(.bottom, 40)
        }
    }
}

#Preview {
    RunningAdvancedMetricsView(selectedTab: .constant(.advanced_metrics))
}
