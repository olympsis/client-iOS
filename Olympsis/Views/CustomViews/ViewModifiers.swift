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
            Rectangle()
                .foregroundColor(Color(uiColor: .secondarySystemBackground))
            Rectangle()
                .stroke(lineWidth: 1)
                .foregroundStyle(Color("color-prime"))
            content
        }.frame(width: SCREEN_WIDTH-25, height: 50)
    }
}


struct SettingButton: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
            content
        }
    }
}


struct InputField: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: 1)
                .foregroundColor(Color("color-prime"))
            content
        }.frame(height: 50)
    }
}
