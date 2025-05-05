//
//  SimpleButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import SwiftUI

struct SimpleButtonLabel: View {
    
    enum STYLE {
        case normal
        case outline
    }
    
    @State var text: String
    @State var style: STYLE = .normal
    @State var width: CGFloat = 150
    @State var height: CGFloat = 40
    
    var body: some View {
        switch style {
        case .normal:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: width, height: height)
                    .foregroundColor(Color("color-prime"))
                Text(text)
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.bold)
                    .italic()
            }
        case .outline:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("color-prime"), lineWidth: 1)
                    .frame(width: width, height: height)
                Text(text)
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.bold)
                    .italic()
            }
        }
    }
}

struct SimpleButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        SimpleButtonLabel(text: "continue", style: .outline)
    }
}
