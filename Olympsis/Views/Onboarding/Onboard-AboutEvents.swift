//
//  Onboard-AboutEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/29/24.
//

import SwiftUI

struct Onboard_AboutEvents: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(String(localized: "onboarding-events-title", table: "Onboarding"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Foreground.default)
            
            Text(String(localized: "onboarding-events-sub-title", table: "Onboarding"))
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding([.horizontal, .vertical])
                .foregroundStyle(Color.Foreground.default)
            
            Image("illustrations/world")
                .resizable()
                .frame(width: SCREEN_WIDTH/1.2, height: SCREEN_WIDTH/1.2)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                SimpleButtonLabel(text: String(localized: "lets-go", table: "General"))
            }
            
            Spacer()
        }
    }
}

#Preview {
    Onboard_AboutEvents()
}
