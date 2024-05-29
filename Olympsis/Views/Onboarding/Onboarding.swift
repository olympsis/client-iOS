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
        TabView(selection: $index) {
            Onboard_AboutOlympsis(index: $index).tag(0)
            Onboard_AboutClubs(index: $index).tag(1)
            Onboard_AboutEvents().tag(2)
        }
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview {
    Onboarding()
}
