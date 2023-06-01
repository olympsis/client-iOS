//
//  Auth.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI
import AuthenticationServices

struct Auth: View {
    
    @State private var log = Logger()
    @Binding var currentView: AuthTab
    @State var userStatus: USER_STATUS?
    @StateObject var observer = AuthObserver()
    
    var body: some View {
        VStack(){
            ZStack {
                Image("basketball-bw")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 2, opaque: true)
                
                VStack {
                    VStack {
                        Image("white-logo")
                            .resizable()
                            .frame(width: 200, height: 200)
                    }.frame(height: SCREEN_HEIGHT/3)
                        
                    Spacer()
                    
                    VStack {
                        Text("Olympsis")
                            .bold()
                            .font(.custom("ITCAvantGardeStd-Bold", size: 35, relativeTo: .largeTitle))
                            .foregroundColor(.white)
                        Text("Join a community made by athletes for athletes.")
                            .frame(width: SCREEN_WIDTH)
                            .multilineTextAlignment(.center)
                            .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                            .foregroundColor(.white)
                        
                    }.padding(.bottom, 75)
                    
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task {
                                do {
                                    let res = try await observer.HandleSignInWithApple(result: result)
                                    await MainActor.run {
                                        userStatus = res
                                        if userStatus == USER_STATUS.New {
                                            currentView = .create
                                        } else if userStatus == USER_STATUS.Returning {
                                            currentView = .permissions
                                        }
                                    }
                                } catch {
                                    log.debug("Sign In cancelled or an error occured: \(error)")
                                }
                            }
                        }
                    ).signInWithAppleButtonStyle(.white)
                        .cornerRadius(10)
                        .frame(width: SCREEN_WIDTH-100, height: 50)
                        .padding(.bottom, 50)
                }
            }
        }
    }
}

struct Auth_Previews: PreviewProvider {
    static var previews: some View {
        Auth(currentView: .constant(.auth))
    }
}
