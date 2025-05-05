//
//  LaunchScreen.swift
//  Olympsis
//
//  Created by Joel on 7/28/23.
//

import SwiftUI

struct LaunchScreen: View {
    
    @Environment(SessionStore.self) private var session
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "0.0"
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea(.all)
                .foregroundColor(Color("dark-color"))
            VStack {
                Spacer()
                Image("white-logo")
                    .resizable()
                    .frame(width: 250, height: 250)
                Spacer()
                VStack {
                    Text("Olympsis")
                        .foregroundColor(.white)
                        .bold()
                    Text(appVersion)
                        .foregroundColor(.white)
                        .font(.caption)
                }.padding(.bottom)
            }.frame(maxWidth: .infinity)
        }.task {
            session.listenToAuthStateChanges()
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
