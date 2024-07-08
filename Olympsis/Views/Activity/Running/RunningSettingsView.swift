//
//  RunningSettingsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/24.
//

import SwiftUI

struct RunningSettingsView: View {
    
    @Binding var selectedTab: WORKOUT_TABS
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }.padding(.horizontal)
            
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
                        Image(systemName: "chevron.right")
                            .imageScale(.large)
                            .foregroundStyle(Color.background)
                    }
            }.padding(.bottom, 40)
        }
    }
}

#Preview {
    RunningSettingsView(selectedTab: .constant(.settings))
}
