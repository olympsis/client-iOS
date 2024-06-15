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
            Text("Local Sports Events")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
            
            Text("Host events for your group and or share it publicly to others to help them reach their goals. ")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding([.horizontal, .vertical])
            
            Image("World-rafiki")
                .resizable()
                .frame(width: SCREEN_WIDTH/1.2, height: SCREEN_WIDTH/1.2)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                SimpleButtonLabel(text: "Let's go")
            }
            
            Spacer()
        }
    }
}

#Preview {
    Onboard_AboutEvents()
}
