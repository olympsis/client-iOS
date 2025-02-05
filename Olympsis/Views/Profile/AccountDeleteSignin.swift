//
//  AccountDeleteSignin.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/7/24.
//

import os
import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct AccountDeleteSignin: View {
    
    @State private var state: LOADING_STATE = .pending
    @State private var nonce: String = randomNonceString()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "account_delete_signin_view")
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                }
                Spacer()
            }.padding(.all)
            
            Text("Are you sure? Sign in again to confirm.")
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            SignInWithAppleButton(
                onRequest: { request in
                    request.nonce = sha256(nonce)
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    Task {
                        switch result {
                        case .success(let authorization):
                            if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                guard let idToken = appleIdCredential.identityToken
                                    .flatMap({ String(data: $0, encoding: .utf8) }) else {
                                    return
                                }
                                
                                let creds = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
                                
                                do {
                                    _ = await session.deleteAccount()
                                    try await Auth.auth().signIn(with: creds)
                                    
                                    dismiss()
                                    return
                                } catch {
                                    log.error("Authentication Failed: \(error.localizedDescription)")
                                    dismiss()
                                    return
                                }
                            } else {
                                log.error("Authentication Failed: no credentials found in result")
                                dismiss()
                                return
                            }
                        case .failure(let error):
                            log.error("Authentication Failed: \(error.localizedDescription)")
                            dismiss()
                        }
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal, 50)
            .padding(.bottom, 50)
            .padding(.top)
            
            Spacer()
        }
    }
}

#Preview {
    AccountDeleteSignin()
}
