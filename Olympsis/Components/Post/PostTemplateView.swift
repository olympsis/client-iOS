//
//  PostTemplateView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/14/23.
//

import SwiftUI

struct PostTemplateView: View {
    @State var type: String
    var body: some View {
        if type == "NO IMAGE" {
            VStack(alignment: .leading){
                HStack {
                   Circle()
                        .foregroundColor(.gray)
                        .frame(width: 35)
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 15)
                    Spacer()
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 15)
                        .padding(.trailing)
                }.padding(.leading)
                HStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: SCREEN_WIDTH/2, height: 15)
                    .padding(.leading)
                    Spacer()
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 25)
                        .padding(.trailing)
                }
            }.frame(width: SCREEN_WIDTH, alignment: .leading)
        } else {
            VStack(alignment: .leading){
                HStack {
                   Circle()
                        .foregroundColor(.gray)
                        .frame(width: 35)
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 15)
                    Spacer()
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 15)
                        .padding(.trailing)
                }.padding(.leading)
                Rectangle()
                    .frame(width: SCREEN_WIDTH, height: 500)
                    .foregroundColor(.gray)
                HStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: SCREEN_WIDTH/2, height: 15)
                    .padding(.leading)
                    Spacer()
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 25)
                        .padding(.trailing)
                }
            }.frame(width: SCREEN_WIDTH, alignment: .leading)
        }
    }
}

struct PostTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        PostTemplateView(type: "N IMAGE")
    }
}
