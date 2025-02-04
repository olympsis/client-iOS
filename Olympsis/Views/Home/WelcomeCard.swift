//
//  WelcomeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//
// This could be a cool idea where we could edit the welcome back message to be more custom.
// Such as if a user just did something cool. Or they've been on a good streak.
// Or scold them if they've been away for too long without any activities.

import os
import SwiftUI

struct WelcomeCard: View {
    
    @EnvironmentObject private var session: SessionStore
    
    private var name: String {
        guard let user = session.user, let name = user.firstName else {
            log.error("Failed to get user's name")
            return ""
        }
        return name
    }
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "welcome_view")
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                if name == "" {
                    Text(String(localized: "Welcome!", table: "General"))
                        .font(.custom("Helvetica Neue", size: 25))
                        .fontWeight(.regular)
                    Text(String(localized: "are you ready to play?", table: "General"))
                        .font(.custom("Helvetica Neue", size: 20))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                } else {
                    Text("\(String(localized: "Welcome back", table: "General")) \(name)")
                        .font(.custom("Helvetica Neue", size: 25))
                        .fontWeight(.regular)
                    Text(String(localized: "ready to play?", table: "General"))
                        .font(.custom("Helvetica Neue", size: 20))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeCard()
        .environmentObject(SessionStore())
}
