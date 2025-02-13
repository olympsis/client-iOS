//
//  Onboard-AboutClubs.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/29/24.
//

import SwiftUI

struct Onboard_AboutClubs: View {
    
    @Binding var index: Int
    
    var body: some View {
        VStack {
            Text("Get into groups with friends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.foreground)
            
            Text("Build your sports community - create groups, bring friends, and meet new players")
                .font(.title2)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(Color.foreground)
            
            Image("illustrations/goals")
                .resizable()
                .frame(width: SCREEN_WIDTH/1.2, height: SCREEN_WIDTH/1.2)
            
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
    Onboard_AboutClubs(index: .constant(1))
}
