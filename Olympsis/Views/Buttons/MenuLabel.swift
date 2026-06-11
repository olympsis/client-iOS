//
//  MenuLabel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/22/24.
//

import SwiftUI

struct MenuLabel: View {
    
    @State var icon: Image
    @State var text: String
    @State var type: MENU_BUTTON_TYPE = .normal
    
    var body: some View {
        switch type {
        case .normal:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(Color.Background.secondary))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray)
                    .opacity(0.2)
                
                HStack(alignment: .center) {
                    
                    icon
                        .foregroundStyle(Color.Foreground.default)
                    Text(text)
                        .foregroundStyle(Color.Foreground.default)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .frame(height: 50)
        case .destructive:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(Color.Background.secondary))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(Color("destructive"))
                
                HStack(alignment: .center) {
                    
                    icon
                        .foregroundStyle(Color("destructive"))
                    Text(text)
                        .foregroundStyle(Color("destructive"))
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .frame(height: 50)
            
        case .start:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(Color.Background.secondary))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.green)
                
                HStack(alignment: .center) {
                    
                    icon
                        .foregroundStyle(.green)
                    Text(text)
                        .foregroundStyle(.green)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .frame(height: 50)
        }
    }
}

#Preview {
    MenuLabel(icon: Image(systemName: "star.fill"), text: "Change Member Rank")
}
