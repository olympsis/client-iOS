//
//  Onboard-AboutOlympsis.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/29/24.
//

import SwiftUI

struct Onboard_AboutOlympsis: View {
    
    @Binding var index: Int
    
    var body: some View {
        VStack {
            Text(String(localized: "onboarding-about-title", table: "Onboarding"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Foreground.default)
            
            Text(String(localized: "onboarding-about-sub-title", table: "Onboarding"))
                .font(.title2)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(Color.Foreground.default)
            
            Image("illustrations/spirit")
                .resizable()
                .frame(width: SCREEN_WIDTH/1.3, height: SCREEN_WIDTH/1.3)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeIn) {
                    index += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(Color.Background.secondary))
                    .background {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.Foreground.default)
                    }
            }
            
            Spacer()
        }
    }
}

#Preview {
    Onboard_AboutOlympsis(index: .constant(0))
}
