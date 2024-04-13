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
    @StateObject private var cacheService = CacheService()
    
    @EnvironmentObject var sessionStore: SessionStore
    
    var log = Logger(subsystem: "com.josephlabs.olympsis", category: "auth_view")
    
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
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task {
                                do {
                                    withAnimation {
                                        state = .loading
                                    }
                                    
                                    let resp = try await observer.handleSignInWithApple(result: result)
                                    if resp == USER_STATUS.new {
                                        withAnimation {
                                            currentView = .username
                                        }
                                    } else if resp == USER_STATUS.returning {
                                        guard let user = cacheService.fetchUser(),
                                              user.uuid != nil else {
                                            withAnimation {
                                                currentView = .username
                                            }
                                            return
                                        }
                                        withAnimation {
                                            if (sessionStore.locationManager.isAuthorized) {
                                                currentView = .notifications
                                            } else {
                                                currentView = .location
                                            }
                                        }
                                    } else if resp == USER_STATUS.unknown {
                                        withAnimation {
                                            currentView = .auth
                                        }
                                    }
                                } catch {
                                    withAnimation {
                                        state = .pending
                                    }
                                    log.error("failed to sign user in: \(error)")
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
        Auth(currentView: .constant(.auth))
    }
}
