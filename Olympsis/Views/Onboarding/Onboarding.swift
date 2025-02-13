//
//  Onboarding.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/29/24.
//

import SwiftUI

struct Onboarding: View {
    @State private var index: Int = 0
    var body: some View {
        VStack {
            HStack { // Index Display
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: index == 0 ? 20 : 10, height: 10)
                    
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: index == 1 ? 20 : 10, height: 10)
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: index == 2 ? 20 : 10, height: 10)
            }.padding(.top)
            
            TabView(selection: $index) { // Onboarding
                Onboard_AboutOlympsis(index: $index).tag(0)
                Onboard_AboutClubs(index: $index).tag(1)
                Onboard_AboutEvents().tag(2)
            }
            .overlay(alignment: .bottomLeading, content: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.Brand.primary)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image("logo/white")
                            .resizable()
                    }
                    .padding(.all)
            })
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background {
            Color.Background.primary
                .ignoresSafeArea()
        }
    }
}

#Preview {
    Onboarding()
}
