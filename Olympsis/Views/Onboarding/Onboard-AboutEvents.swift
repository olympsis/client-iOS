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
            Text("Create Sports Events")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.foreground)
            
            Text("Make events exclusive to your group or share them with the community to inspire others")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding([.horizontal, .vertical])
                .foregroundStyle(Color.foreground)
            
            Image("illustrations/world")
                .resizable()
                .frame(width: SCREEN_WIDTH/1.2, height: SCREEN_WIDTH/1.2)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                SimpleButtonLabel(text: "Let's go")
            }
            
            Spacer()
        }
        .background {
            Color.Background.primary
        }
    }
}

#Preview {
    Onboard_AboutEvents()
}
