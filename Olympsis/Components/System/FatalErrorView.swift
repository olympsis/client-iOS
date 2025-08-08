//
//  FatalErrorView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/8/25.
//

import SwiftUI

struct FatalErrorView: View {
    var body: some View {
        VStack {
            Text("Fatal Error!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.red)
            
            Text("Something critical went wrong. Please try again later or restart the application")
                .font(.title2)
                .padding(.horizontal)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    FatalErrorView()
}
