//
//  ViewModifiers.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI
import Foundation

struct MenuButton: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
            content
        }.frame(width: SCREEN_WIDTH-25, height: 50)
    }
}

