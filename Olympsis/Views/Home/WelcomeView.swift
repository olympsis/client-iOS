//
//  WelcomeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var firstName: String
    @Binding var status: LOADING_STATE
    var body: some View {
        VStack(alignment: .leading){
            if status == .success {
                Text("Welcome back \(firstName)")
                    .font(.custom("Helvetica Neue", size: 25))
                    .fontWeight(.regular)
                Text("ready to play?")
                    .font(.custom("Helvetica Neue", size: 20))
                    .fontWeight(.light)
                    .foregroundColor(.gray)
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
        WelcomeView(firstName: .constant("Joel"), status: .constant(.success))
    }
}
