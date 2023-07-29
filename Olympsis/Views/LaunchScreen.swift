//
//  LaunchScreen.swift
//  Olympsis
//
//  Created by Joel on 7/28/23.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea(.all)
                .foregroundColor(Color("dark-color"))
            VStack {
                Spacer()
                Image("white-logo")
                    .resizable()
                    .frame(width: 200, height: 200)
                Spacer()
                VStack {
                    Text("Olympsis")
                        .foregroundColor(.white)
                        .bold()
                    Text("0.4.5")
                        .foregroundColor(.white)
                        .font(.caption)
                }.padding(.bottom)
            }.frame(maxWidth: .infinity)
            
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
