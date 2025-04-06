//
//  LocationUsage.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/30/24.
//

import SwiftUI

struct LocationUsage: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Text("I Understand")
                }
            }.padding(.horizontal)
            ScrollView {
                Text("How location is used on Olympsis")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .bold()
                    .padding(.vertical)
                
                Image(systemName: "map.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.bottom)
                    .foregroundStyle(Color("color-prime"))
                
                Text("""
                    On Olympsis, your location data is utilized solely to enhance your experience by recommending relevant sports events in your area. Your privacy is of utmost importance, and your location information will never be shared with any third parties. It is used exclusively by Olympsis to provide you with personalized event recommendations based on your proximity.
                
                    If you prefer not to share your precise location, you can allow coarse location tracking, or simply set your hometown. This way, we can still suggest events that may be of interest to you within your general vicinity.
                
                    Rest assured that you have full control over your location settings. You can always adjust your preferences or opt-out of location tracking entirely if you so choose. Our goal is to tailor the app's functionality to your needs while respecting your privacy.
                """)
                Spacer()
            }.padding(.horizontal)
        }
    }
}

#Preview {
    LocationUsage()
}
