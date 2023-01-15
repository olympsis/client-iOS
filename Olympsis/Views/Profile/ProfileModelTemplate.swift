//
//  ProfileModelTemplate.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/16/22.
//

import SwiftUI

struct ProfileModelTemplate: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    Color.gray // Acts as a placeholder.
                        .clipShape(Circle())
                        .opacity(0.3)
                }.frame(width: 100, height: 100)
                
                VStack(alignment: .leading){
                    Rectangle()
                        .frame(width: SCREEN_WIDTH/2, height: 30)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                    Rectangle()
                        .frame(width: 100, height: 20)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                }.padding(.leading)
            }
            Rectangle()
                .frame(width: SCREEN_WIDTH-30, height: 15)
                .padding(.top)
                .foregroundColor(.gray)
                .opacity(0.3)
            Rectangle()
                .frame(width: SCREEN_WIDTH-30, height: 15)
                .foregroundColor(.gray)
                .opacity(0.3)
            
        }
    }
}

struct ProfileModelTemplate_Previews: PreviewProvider {
    static var previews: some View {
        ProfileModelTemplate()
    }
}
