//
//  ClubLoadingView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/2/24.
//

import SwiftUI

struct ClubLoadingView: View {
    var body: some View {
        ScrollView {
            HStack {
                Text("Club Name")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "plus.square.dashed")
                    .imageScale(.large)
                    .padding(.horizontal, 5)
                
                Image(systemName: "bubble.left.and.bubble.right")
                    .imageScale(.large)
                    .padding(.horizontal, 5)
                
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 35, height: 35)
            }
            .padding(.horizontal)
            .redacted(reason: .placeholder)
            
            ForEach(0..<3, id: \.self) { _ in
                PostTemplateView()
                    .environmentObject(SessionStore())
            }
        }
    }
}

#Preview {
    ClubLoadingView()
}
