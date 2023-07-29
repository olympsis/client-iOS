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
    
    @Binding var currentView: AuthTab
    @State private var state: LOADING_STATE = .pending
    @StateObject private var observer = AuthObserver()
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "auth_view")
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        VStack(){
            ZStack(alignment: .center) {
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
                                    state = .loading
                                    let resp = try await observer.handleSignInWithApple(result: result)
                                    if resp == USER_STATUS.new {
                                        currentView = .username
                                    } else if resp == USER_STATUS.returning {
                                        await sessionStore.generateUserData()
                                        guard let user = sessionStore.user,
                                              user.uuid != nil,
                                              user.username != nil else {
                                            currentView = .username
                                            return
                                        }
                                        currentView = .location
                                    }
                                } catch {
                                    state = .pending
                                    log.error("failed to sign user in: \(error)")
                                }
                            }
                        }
                    ).signInWithAppleButtonStyle(.white)
                        .cornerRadius(10)
                        .frame(width: SCREEN_WIDTH-100, height: 50)
                        .padding(.bottom, 50)
                }
                if state == .loading {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .opacity(0.8)
                            .blur(radius: 5)
                        ProgressView()
                    }
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
