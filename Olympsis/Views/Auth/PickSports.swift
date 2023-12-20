//
//  PickSports.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import os
import SwiftUI

struct PickSports: View {
    
    @Binding var currentView: AuthTab
    
    @State private var status: LOADING_STATE = .pending
    @State private var selectedSports = [SPORT]()
    @State private var cacheService = CacheService()
    @State private var userObserver = UserObserver()
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "pick_sports_view")
    
    func createUserData() async {
        
        // re initializing user observer hoping that auth issue will be fixed
        userObserver = UserObserver()
        
        guard var user = cacheService.fetchUser(),
              let username = user.username else {
            handleFailure()
            return
        }
        status = .loading
        let sports = selectedSports.map({ return $0.rawValue })
        do {
            guard let data = try await userObserver.createUserData(username: username, sports: sports) else {
                handleFailure()
                return
            }
            user.sports = data.sports
            cacheService.cacheUser(user: user)
            handleSuccess()
        } catch {
            log.error("failed to create user: \(error.localizedDescription)")
            handleFailure()
            return
        }
    }
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func handleSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            currentView = .location
        }
    }
    
    var body: some View {
        VStack {
            // title
            ZStack {
                Rectangle()
                    .foregroundStyle(Color("background"))
                    .ignoresSafeArea(.all)
                    .frame(height: 100)
                Text("What’s your fav sports?")
                    .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                    .fontWeight(.medium)
                    .padding(.top)
                    .foregroundStyle(Color("foreground"))
            }.frame(width: SCREEN_WIDTH)
            SportsPicker(selectedSports: $selectedSports)
                .padding(.top, 25)
            Button(action: {
                Task(priority: .high) {
                    await createUserData()
                }
            }) {
                LoadingButton(text: "create", width: 150, status: $status)
                    .padding(.horizontal, 30)
            }.padding(.bottom)
                .disabled(!(selectedSports.count > 0))
                
        }
    }
}

struct PickSports_Previews: PreviewProvider {
    static var previews: some View {
        PickSports(currentView: .constant(.sports))
    }
}
