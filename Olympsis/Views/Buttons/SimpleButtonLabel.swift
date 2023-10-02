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
    var body: some View {
        switch style {
        case .normal:
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 150, height: 45)
                    .foregroundColor(Color("color-prime"))
                Text(text)
                    .foregroundColor(.white)
                    .font(.headline)
            }
        case .outline:
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("color-prime"), lineWidth: 1)
                    .frame(width: 150, height: 45)
                Text(text)
                    .foregroundColor(.primary)
                    .font(.headline)
            }
        }
    }
}

struct SimpleButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        SimpleButtonLabel(text: "continue", style: .outline)
    }
}
