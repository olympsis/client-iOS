//
//  Notifications.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/19/23.
//

import os
import SwiftUI

struct Notifications: View {
    
    @Binding var currentView: AuthTab
    
    @State private var status: LOADING_STATE = .pending
    @State private var userObserver = UserObserver()
    @State private var notifications = NotificationsManager()
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "notification_permission_view")
    
    @AppStorage("deviceToken") private var deviceToken: String?
    @EnvironmentObject private var sessionStore: SessionStore
    func handleAllow() async {
        do {
            try await notifications.requestAuthorization()
            guard let tk = deviceToken else {
                status = .failure
                return
            }
            _ = await userObserver.UpdateUserData(update: User(deviceToken: tk))
            status = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sessionStore.authStatus = .authenticated
            }
        } catch {
            status = .failure
            log.error("failed to allow notifications: \(error.localizedDescription)")
        }
    }
    
    func handleNoThanks() {
        
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Can we notify you? 🥹")
                    .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                    .fontWeight(.medium)
                Text("In order to notify you of local events, and club activities we need to be able to send you notifications.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }.padding(.horizontal)
                .padding(.top)
            
            Spacer()
            
            switch status {
            case .success:
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
            case .failure:
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
            default:
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("color-prime"))
            }
            
            Spacer()
            
            VStack {
                Button(action: { Task { await handleAllow() }}) {
                    SimpleButtonLabel(text: "Allow")
                }
                
                Button(action:{}) {
                    Text("No Thanks")
                        .foregroundColor(.primary)
                        .bold()
                }.padding(.top)
            }
            .padding(.bottom)
        }.task {
            // token initialization issue fix
            userObserver = UserObserver()
        }
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications(currentView: .constant(.notifications))
    }
}
