//
//  FieldViewTemplate.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI

struct FieldViewTemplate: View {
    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.3)
                .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
            HStack {
                VStack(alignment: .leading){
                   Rectangle()
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: 150, height: 20)
                    Rectangle()
                         .foregroundColor(.gray)
                         .opacity(0.3)
                         .frame(width: 300, height: 20)
                }.padding(.leading)
                
                Spacer()
                
                VStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: 40)
                        .padding(.trailing)
                }.frame(height: 40)
            }.frame(height: 40)
        }
    }
}

struct FieldViewTemplate_Previews: PreviewProvider {
    static var previews: some View {
        FieldViewTemplate()
    }
}
