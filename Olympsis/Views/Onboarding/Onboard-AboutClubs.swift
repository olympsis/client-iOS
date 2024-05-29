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
            Text("Get into clubs with friends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])
                .multilineTextAlignment(.center)
            
            Text("Create clubs with friends and make new friends and reach new heights together")
                .font(.title2)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image("Team goals-amico")
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
    Onboard_AboutClubs(index: .constant(1))
}
