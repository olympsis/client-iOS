//
//  Auth.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI
//import AlertToast
import AuthenticationServices

struct AuthView: View {
    
    @Binding var currentView: AuthTab
    
    // Bindings to pass Apple credential data back to AuthContainer
    @Binding var appleFirstName: String?
    @Binding var appleLastName: String?
    @Binding var appleEmail: String?
    
    @State private var showToast: Bool = false
    @State private var enableLogin: Bool = false
    
    @State private var state: LOADING_STATE = .pending
    @State private var nonce: String = randomNonceString()
    
    private let observer = AuthObserver()
    private let cacheService = CacheService()
    private let managementService = ManagementService()
    
    @Environment(SessionStore.self) var session
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    var log = Logger(subsystem: "com.olympsis.client", category: "auth_view")
    
    var body: some View {
        VStack {
            VStack {
                Image("logo/white")
                    .resizable()
                    .frame(width: 250, height: 250)
            }.frame(height: SCREEN_HEIGHT/3)
                
            Spacer()
            
            VStack {
                VStack {
                    Text("Olympsis")
                        .padding(.top, 25)
                        .padding(.bottom, 5)
                        .foregroundColor(.white)
                        .font(.custom("Archivo-Black", size: 25, relativeTo: .title))
                    
                    Text(String(localized: "slogan", table: "General"))
                        .font(.title3)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }.frame(width: SCREEN_WIDTH)
                
                
                switch state {
                case .pending, .success, .failure:
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.nonce = sha256(nonce)
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            // Capture Apple credential data for AuthUserInfo
                            if case .success(let authorization) = result,
                               let cred = authorization.credential as? ASAuthorizationAppleIDCredential {
                                appleFirstName = cred.fullName?.givenName
                                appleLastName = cred.fullName?.familyName
                                appleEmail = cred.email
                            }
                            
                            Task {
                                do {
                                    withAnimation {
                                        state = .loading
                                    }
                                    
                                    let resp = try await observer.handleSignInWithApple(result: result, nonce: nonce)
                                    if resp == USER_STATUS.new {
                                        withAnimation {
                                            currentView = .info
                                        }
                                    } else if resp == USER_STATUS.returning {
                                        // Load cached user into session immediately so
                                        // profile data is available before ViewContainer appears
                                        session.user = cacheService.fetchUser()
                                        withAnimation {
                                            authStatus = .authenticated
                                        }
                                    } else if resp == USER_STATUS.not_finished {
                                        withAnimation {
                                            currentView = .info
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
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .overlay {
                        if !enableLogin {
                            Color.gray
                                .opacity(0.9)
                                .cornerRadius(radius: 5, corners: .allCorners)
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 50)
                    .padding(.top)
                    .disabled(!enableLogin)
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
        }
        .background {
            Image("basketball-bw")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 2, opaque: true)
        }
        .task {
            // If server is down we don't want people signing up
            guard await managementService.wsg() else {
                showToast = true
                return
            }
            enableLogin = true
        }
    }
}

#Preview {
    AuthView(currentView: .constant(.auth), appleFirstName: .constant(nil), appleLastName: .constant(nil), appleEmail: .constant(nil))
        .environment(SessionStore())
}
