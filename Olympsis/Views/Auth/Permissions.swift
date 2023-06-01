//
//  Permissions.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI

struct Permissions: View {
    
    @Binding var currentView: AuthTab
    
    @State private var log = Logger()
    @State private var hasLocation = false;
    @State private var hasNotifications = false;
    @State private var location = LocationObserver()
    @State private var notifications = NotificationsManager()
    
    @State private var userObserver = UserObserver()
    
    @AppStorage("authToken") var authToken: String?
    @AppStorage("loggedIn") private var loggedIn: Bool?
    @AppStorage("deviceToken") private var deviceToken: String?
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(){
                Text("One more thing 😅, we need your permission for a couple of things: ")
                    .font(.largeTitle)
                    .bold()
                    .frame(width: SCREEN_WIDTH-50)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Text("To provide a better experience and more accurate data, we need to have your location even when the app is in the background.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(width: SCREEN_WIDTH-50)
                    .padding(.top, 20)
                
                Button(action:{
                    Task {
                        try await location.requestAuthorization()
                        hasLocation = true
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("primary-color"))
                            .frame(width: 250, height: 45)
                            
                        Text("location")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }
                }.padding(.top)
                
                
                Text("In order to notify you of local events, and club activities we need to be able to send you notifications.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(width: SCREEN_WIDTH-50)
                    .padding(.top, 50)
                
                Button(action:{
                    Task {
                        try await notifications.requestAuthorization()
                        hasNotifications = true
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("primary-color"))
                            .frame(width: 250, height: 45)
                            
                        Text("notifications")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }
                }.padding(.top)
                
                Button(action: {
                    self.loggedIn = true
                    Task {
                        if let tk = deviceToken {
                            // update device token
                            userObserver = UserObserver()
                            let u = User(deviceToken: tk)
                            _ = await userObserver.UpdateUserData(update: u)
                        }
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("primary-color"))
                            .frame(width: 100, height: 45)
                        Text("done")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }
                }.padding(.bottom)
                    .padding(.top, 80)
            }
        }
    }
}

struct Permissions_Previews: PreviewProvider {
    static var previews: some View {
        Permissions(currentView: .constant(.permissions))
            .environmentObject(SessionStore())
    }
}
