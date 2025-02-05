//
//  LocationRequestView.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/12/24.
//

import SwiftUI

struct LocationRequestView: View {
    
    @State private var location = LocationManager()
    @State private var coordinates: [Double] = []
    @State private var showHomeTown: Bool = false
    @State private var showExplination: Bool = false
    @State private var status: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    func handleAllow() async {
        location.requestLocation()
        dismiss()
    }
    
    func handleDeny() async {
        dismiss()
    }
    
    var body: some View {
        VStack {
            Text(String(localized: "Share Your Location", table: "General"))
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
            
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
            Text(String(localized: "Olympsis needs to access your location to show you nearby sports events and tournaments happening in your area. Olympsis will curate the optimal local sports experience for you based on your proximity. This ensures you never miss out on the biggest games or can easily discover new sporting events in your vicinity.", table: "General"))
                .multilineTextAlignment(.center)
                .padding(.all)
            Spacer()
            
            VStack {
                Button(action: { Task { await handleAllow() }}) {
                    SimpleButtonLabel(text: String(localized: "Allow", table: "General"))
                }
                
                Button(action:{ self.showHomeTown.toggle() }) {
                    Text(String(localized: "No Thanks", table: "General"))
                        .foregroundStyle(.gray)
                        .font(.callout)
                }.padding(.top)
                    .fullScreenCover(isPresented: $showHomeTown, onDismiss: { dismiss() }, content: {
                        HometownPicker(hometown: $coordinates)
                    })
                
                
                Button(action: { self.showExplination.toggle() }) {
                    Text(String(localized: "How is my location used?", table: "General"))
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

#Preview {
    LocationRequestView()
        .environment(SessionStore())
}
