//
//  BlinkingCircle.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI
import Foundation

struct BlinkingCircle: View {
    @State private var isVisible = false
    var body: some View {
        Circle()
            .fill(Color.red)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                    self.isVisible.toggle()
                }
            }
    }
}
