//
//  Location.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/19/23.
//

import os
import SwiftUI
import CoreLocation

struct Location: View {
    
    @State private var userObserver = UserObserver()
    @State private var location = LocationObserver()
    @State private var notifications = NotificationsManager()
    
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "location_permission_view")
    
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack {
            VStack {
                Text("So where's home? 😅")
                    .font(.title)
                    .bold()
                Text("To help you find fields in the area and trigger events in the app, we need to have your location even when the app is in the background.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }.frame(width: SCREEN_WIDTH-20)
            
            Spacer()
            
            Image(systemName: "location.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color("primary-color"))
            
            Spacer()
            
            VStack {
                Button(action: {}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("primary-color"))
                            .frame(width: 150, height: 40)
                        Text("Allow")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                
                Button(action:{}) {
                    Text("How is my location used?")
                        .foregroundColor(.primary)
                        .bold()
                }.padding(.top)
            }
        }
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Location()
    }
}
