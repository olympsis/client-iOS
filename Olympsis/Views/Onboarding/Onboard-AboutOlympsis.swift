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
            Text("Welcome to Olympsis")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.foreground)
            
            Text("Your platform to build thriving communities around the sports that bring us together")
                .font(.title2)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(Color.foreground)
            
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
                    .foregroundStyle(Color("background"))
                    .background {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.foreground)
                    }
            }
            
            Spacer()
        }
        .background {
            Color.background
        }
    }
}

#Preview {
    Onboard_AboutOlympsis(index: .constant(0))
}
