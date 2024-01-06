//
//  MenuButton.swift
//  Olympsis
//
//  Created by Joel on 1/2/24.
//

import SwiftUI

enum MENU_BUTTON_TYPE {
    case normal
    case destructive
}

struct MenuButton: View {
    
    @State var icon: Image
    @State var text: String
    @State var action: () -> Void = {}
    @State var type: MENU_BUTTON_TYPE = .normal
    
    var body: some View {
        Button(action: action) {
            switch type {
            case .normal:
                ZStack {
                    Rectangle()
                        .foregroundStyle(Color("background"))
                    Rectangle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.gray)
                        .opacity(0.2)
                    
                    HStack(alignment: .center) {
                        
                        icon
                            .foregroundStyle(Color("foreground"))
                        Text(text)
                            .foregroundStyle(Color("foreground"))
                        Spacer()
                    }.padding(.horizontal)
                }.padding(.horizontal)
            case .destructive:
                ZStack {
                    Rectangle()
                        .foregroundStyle(Color("background"))
                    Rectangle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color("destructive"))
                    
                    HStack(alignment: .center) {
                        
                        icon
                            .foregroundStyle(Color("destructive"))
                        Text(text)
                            .foregroundStyle(Color("destructive"))
                        Spacer()
                    }.padding(.horizontal)
                }.padding(.horizontal)
            }
        }.frame(height: 50)
    }
}

#Preview {
    MenuButton(icon: Image(systemName: "star.fill"), text: "Change Member Rank")
}
