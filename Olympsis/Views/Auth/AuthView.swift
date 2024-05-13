//
//  Auth.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI
import AuthenticationServices

struct AuthView: View {
    
    @Binding var currentView: AuthTab
    @State private var state: LOADING_STATE = .pending
    @State private var nonce: String = randomNonceString()
    
    @StateObject private var observer = AuthObserver()
    @StateObject private var cacheService = CacheService()
    
    @EnvironmentObject var sessionStore: SessionStore
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    var log = Logger(subsystem: "com.josephlabs.olympsis", category: "auth_view")
    
    var usernameCompleted: Bool {
        let user = cacheService.fetchUser()
        guard user?.username != nil,
              user?.username != "" else {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack {
            VStack {
                Image("white-logo")
                    .resizable()
                    .frame(width: 250, height: 250)
            }.frame(height: SCREEN_HEIGHT/3)
                
            Spacer()
            
            VStack {
                VStack {
                    Text("Olympsis")
                        .bold()
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 25)
                        .padding(.bottom, 5)
                    Text("Join a community made by athletes for athletes.")
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .foregroundColor(.white)
                }.frame(width: SCREEN_WIDTH)
                
                
                switch state {
                case .pending, .success, .failure:
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.nonce = sha256(nonce)
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task {
                                do {
                                    withAnimation {
                                        state = .loading
                                    }
                                    
                                    let resp = try await observer.handleSignInWithApple(result: result, nonce: nonce)
                                    if resp == USER_STATUS.new {
                                        withAnimation {
                                            currentView = .username
                                        }
                                    } else if resp == USER_STATUS.returning {
                                        withAnimation {
                                            authStatus = .authenticated
                                        }
                                    } else if resp == USER_STATUS.not_finished {
                                        guard usernameCompleted else {
                                            withAnimation {
                                                currentView = .username
                                            }
                                            return
                                        }
                                        withAnimation {
                                            currentView = .sports
                                        }
                                    } else if resp == USER_STATUS.unknown {
                                        withAnimation {
                                            state = .pending
                                            log.error("Failed gracefully. Unknown user status returned.")
                                        }
                                    }
                                } catch {
                                    withAnimation {
                                        state = .pending
                                    }
                                    log.error("Failed to sign user in: \(error)")
                                }
                            }
                        }
                    ).signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 50)
                        .padding(.top)
                case .loading:
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 50)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 50)
                        .padding(.top)
                        .foregroundStyle(.white)
                        .overlay {
                            ProgressView()
                                .padding(.bottom, 35)
                        }
                }
                
            }.background {
                Rectangle()
                    .foregroundStyle(.black)
                    .background(.thinMaterial)
                    .opacity(0.6)
                    .ignoresSafeArea(edges: .bottom)
            }
        }.background {
            Image("basketball-bw")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 2, opaque: true)
        }
    }
}

struct Auth_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(currentView: .constant(.auth))
    }
}
