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
    
    @State private var status: LOADING_STATE = .pending
    @State private var location = LocationObserver()
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "location_permission_view")
    
    func handleAllow() async {
        do {
            try await location.requestAuthorization()
            status = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                currentView = .notifications
            }
        } catch {
            status = .failure
            log.error("failed to request location authorization: \(error.localizedDescription)")
        }
    }
    
    func handleNoThanks() {
        status = .failure
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("So where's home? 😅")
                    .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                    .fontWeight(.medium)
                Text("To help you find fields in the area and trigger events in the app, we need to have your location even when the app is in the background.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }.padding(.horizontal)
                .padding(.top)
            
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
                    .foregroundColor(Color("primary-color"))
            }
            
            Spacer()
            
            VStack {
                Button(action: { Task { await handleAllow() }}) {
                    SimpleButtonLabel(text: "Allow")
                }
                
                Button(action:{}) {
                    Text("How is my location used?")
                        .foregroundColor(.primary)
                        .bold()
                }.padding(.top)
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
