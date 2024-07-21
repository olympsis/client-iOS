//
//  StartActivityButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct StartActivityButton: View {
    
    var sport: SPORTS
    var action: () -> ()
    
    init(_ sport: SPORTS, action: @escaping () -> ()) {
        self.sport = sport
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 100)
                .foregroundStyle(Color.colorSecnd)
                .padding(.horizontal)
                .overlay {
                    VStack(spacing: 3) {
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                        Text("start")
                            .font(.title)
                            .italic()
                            .fontWeight(.black)
                            .textCase(.uppercase)
                    }
                    .foregroundStyle(Color.white)
                }
        }
    }
}

#Preview {
    StartActivityButton(.running, action: {})
}
