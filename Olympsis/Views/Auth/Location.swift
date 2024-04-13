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
    
    @Binding var currentView: AuthTab
    @State private var coordinates: [Double] = []
    @State private var showHomeTown: Bool = false
    @State private var showExplination: Bool = false
    @State private var status: LOADING_STATE = .pending
    @State private var location = LocationManager()
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "location_permission_view")
    
    
    func handleAllow() async {
        location.requestLocation()
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            currentView = .notifications
        }
    }
    
    func handleNoThanks() {
        status = .failure
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("So, where are you? 👀")
                    .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                    .fontWeight(.medium)
                Text("To help you find fields in the area and trigger events in the app, we need to have your location even when the app is in the background.")
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .font(.callout)
                    .padding(.horizontal)
            }.frame(width: SCREEN_WIDTH)
            .padding(.horizontal)
                .padding(.vertical)
                .background {
                    Rectangle()
                        .foregroundStyle(Color("background"))
                        .ignoresSafeArea(.all)
                }
            
            Spacer()
            
            
            switch status {
            case .success:
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
            case .failure:
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
            default:
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("color-prime"))
            }
            
            Spacer()
            
            VStack {
                Button(action: { Task { await handleAllow() }}) {
                    SimpleButtonLabel(text: "Allow")
                }
                
                Button(action:{ self.showHomeTown.toggle() }) {
                    Text("No Thanks")
                        .foregroundColor(.primary)
                        .font(.callout)
                }.padding(.top)
                    .fullScreenCover(isPresented: $showHomeTown, onDismiss: { currentView = .notifications }, content: {
                        HometownPicker(hometown: $coordinates)
                    })
                
                
                Button(action: { self.showExplination.toggle() }) {
                    Text("How is my location used?")
                        .foregroundColor(.primary)
                        .font(.callout)
                }.padding(.top)
                    .fullScreenCover(isPresented: $showExplination, content: {
                        LocationUsage()
                    })
            }
            .padding(.bottom)
        }
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Location(currentView: .constant(.location))
    }
}
