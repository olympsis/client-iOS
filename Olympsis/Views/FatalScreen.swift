//
//  FatalScreen.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/26.
//

import SwiftUI

struct FatalScreen: View {
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "0.0"
        }
    }
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea(.all)
                .foregroundColor(Color("dark-color"))
            VStack {
                Image("logo/white")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)
                
                Spacer()
                
                VStack {
                    Text("Something went wrong")
                        .foregroundColor(.white)
                        .bold()
                    Text("Please try again later")
                        .italic()
                        .foregroundColor(.white)
                }
                
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
        }
    }

}

#Preview {
    FatalScreen()
        .environment(SessionStore())
}
