//
//  Permissions.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI

struct Permissions: View {
    
    @Binding var currentView: AuthTab

    @State private var hasLocation = false;
    @State private var hasNotifications = false;
    @State private var location = LocationObserver()
    @State private var notifications = NotificationsObserver()
    
    @EnvironmentObject var session: SessionStore
    @AppStorage("loggedIn") private var loggedIn: Bool?
    
    var body: some View {
        VStack(){
            Text("One more thing 😅, we need your permission for a couple of things: ")
                .font(.custom("ITCAvantGardeStd-Md", size: 30, relativeTo: .title))
                .frame(width: SCREEN_WIDTH-50)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            Text("To provide a better experience and more accurate data, we need to have your location even when the app is in the background.")
                .font(.custom("ITCAvantGardeStd-Bk", size: 20, relativeTo: .body))
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
                        .font(.custom("ITCAvantGardeStd-bold", size: 20, relativeTo: .body))
                }
            }.padding(.top)
            
            
            Text("In order to notify you of local events, and club activities we need to be able to send you notifications.")
                .font(.custom("ITCAvantGardeStd-Bk", size: 20, relativeTo: .body))
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
                        .font(.custom("ITCAvantGardeStd-bold", size: 20, relativeTo: .body))
                }
            }.padding(.top)
            Spacer()
            
            Button(action: {
                session.fetchDataFromCache()
                self.loggedIn = true
                
            }){
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("primary-color"))
                        .frame(width: 100, height: 45)
                    Text("done")
                        .foregroundColor(.white)
                        .font(.custom("ITCAvantGardeStd-bold", size: 20, relativeTo: .body))
                }
            }.padding(.bottom)
                
        }
    }
}

struct Permissions_Previews: PreviewProvider {
    static var previews: some View {
        Permissions(currentView: .constant(.permissions))
    }
}
