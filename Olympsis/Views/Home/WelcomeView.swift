//
//  WelcomeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct WelcomeView: View {
    @State var name: String
    @Binding var status: LOADING_STATE
    var body: some View {
        VStack(alignment: .leading){
            if status == .success {
                if name == "" {
                    Text(String(localized: "Welcome!", table: "General"))
                        .font(.custom("Helvetica Neue", size: 25))
                        .fontWeight(.regular)
                    Text(String(localized: "are you ready to play?", table: "General"))
                        .font(.custom("Helvetica Neue", size: 20))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                } else {
                    Text("\(String(localized: "Welcome back", table: "General")) \(name)")
                        .font(.custom("Helvetica Neue", size: 25))
                        .fontWeight(.regular)
                    Text(String(localized: "ready to play?", table: "General"))
                        .font(.custom("Helvetica Neue", size: 20))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                }
            } else {
                Rectangle()
                    .frame(width: SCREEN_WIDTH/1.3, height: 30)
                    .foregroundColor(.gray)
                    .opacity(0.3)

                Rectangle()
                    .frame(width: 150, height: 20)
                    .foregroundColor(.gray)
                    .opacity(0.3)
            }
        }.padding(.leading)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(name: "Joel", status: .constant(.success))
    }
}
