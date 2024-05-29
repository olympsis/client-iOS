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
            
            Text("A new social platform for athletes(everyone) to create communities around the sports they love.")
                .font(.title2)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image("Team spirit-amico")
                .resizable()
                .frame(width: SCREEN_WIDTH/1.2, height: SCREEN_WIDTH/1.2)
            
            Spacer()
            
            Button(action: { index += 1 }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("background"))
                    .background {
                        Circle()
                            .frame(width: 50, height: 50)
                    }
            }
            
            Spacer()
        }
    }
}

#Preview {
    Onboard_AboutOlympsis(index: .constant(0))
}
