//
//  AboutUs.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import SwiftUI

struct AboutUs: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            HStack {
                Text(String(localized: "about-olympsis-title", table: "Settings"))
                    .padding(.all)
                    .font(.title3)
                    .bold()
                Spacer()
            }
            Text(String(localized: "about-olympsis-body", table: "Settings"))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .navigationTitle(String(localized: "setting-about-us", table: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutUs()
    }
}
